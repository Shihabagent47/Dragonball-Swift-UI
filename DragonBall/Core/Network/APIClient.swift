//
//  APIClient.swift
//  DragonBall
//

import Foundation

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    /// Fetches and decodes a `Decodable` response from a given `APIEndpoint`.
    func fetch<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.badURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
