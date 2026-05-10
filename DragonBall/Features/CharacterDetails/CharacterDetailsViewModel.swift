//
//  CharacterDetailsViewModel.swift
//  DragonBall
//

import Foundation

@Observable
@MainActor
final class CharacterDetailsViewModel {

    private(set) var detail: CharacterDetail?
    private(set) var isLoading = false
    private(set) var error: NetworkError?

    private let characterId: Int
    private let apiClient: APIClient

    init(characterId: Int, apiClient: APIClient = .shared) {
        self.characterId = characterId
        self.apiClient = apiClient
    }

    func load() async {
        guard detail == nil else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            detail = try await apiClient.fetch(.characterDetail(id: characterId))
        } catch let networkError as NetworkError {
            self.error = networkError
        } catch {
            self.error = .unknown(error)
        }
    }
}
