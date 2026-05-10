//
//  CharacterListViewModel.swift
//  DragonBall
//

import Foundation

@Observable
@MainActor
final class CharacterListViewModel {

    // MARK: - Public State

    private(set) var characters: [Character] = []
    private(set) var isLoading = false
    private(set) var error: NetworkError?
    private(set) var hasMorePages = true

    // MARK: - Private State

    private var currentPage = 1
    private let pageLimit = 10
    private var isFetching = false

    // MARK: - Dependencies

    private let apiClient: APIClient

    // MARK: - Init

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - Public API

    /// Call on first appearance to load the initial page.
    func loadInitial() async {
        guard characters.isEmpty else { return }
        await fetch(page: 1)
    }

    /// Call when the pagination sentinel appears to load the next page.
    func loadNextPage() async {
        guard hasMorePages, !isFetching else { return }
        await fetch(page: currentPage)
    }

    /// Clears all state and reloads from page 1.
    func refresh() async {
        characters = []
        currentPage = 1
        hasMorePages = true
        error = nil
        await fetch(page: 1)
    }

    // MARK: - Private Fetch

    private func fetch(page: Int) async {
        guard !isFetching else { return }

        isFetching = true
        isLoading = true
        error = nil

        defer {
            isFetching = false
            isLoading = false
        }

        do {
            let result: CharacterPage = try await apiClient.fetch(
                .characters(page: page, limit: pageLimit)
            )

            // Append new characters avoiding duplicates
            let existingIDs = Set(characters.map(\.id))
            let newCharacters = result.characters.filter { !existingIDs.contains($0.id) }
            characters.append(contentsOf: newCharacters)

            // Advance page cursor and check if more pages exist
            currentPage = result.meta.currentPage + 1
            hasMorePages = result.meta.currentPage < result.meta.totalPages

        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = .unknown(error)
        }
    }
}
