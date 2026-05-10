//
//  CachedAsyncImage.swift
//  DragonBall
//

import SwiftUI

/// Drop-in replacement for AsyncImage that caches responses in memory + disk.
/// Uses a shared URLCache (50 MB memory / 200 MB disk).
struct CachedAsyncImage<Content: View, Placeholder: View>: View {

    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var image: UIImage?

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let uiImage = image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .task { await load() }
            }
        }
    }

    private func load() async {
        guard let url else { return }

        // Check memory/disk cache first
        let request = URLRequest(url: url)
        if let cached = ImageCache.shared.cachedResponse(for: request),
           let uiImage = UIImage(data: cached.data) {
            image = uiImage
            return
        }

        // Fetch and store in cache
        guard let (data, response) = try? await URLSession.shared.data(from: url),
              let uiImage = UIImage(data: data) else { return }

        let cachedResponse = CachedURLResponse(response: response, data: data)
        ImageCache.shared.storeCachedResponse(cachedResponse, for: request)
        image = uiImage
    }
}

// MARK: - Shared cache configuration

enum ImageCache {
    static let shared: URLCache = {
        URLCache(
            memoryCapacity: 50 * 1024 * 1024,   // 50 MB memory
            diskCapacity:   200 * 1024 * 1024,   // 200 MB disk
            diskPath:       "dragonball_image_cache"
        )
    }()
}
