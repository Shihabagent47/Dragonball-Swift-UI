//
//  NetworkError.swift
//  DragonBall
//

import Foundation

enum NetworkError: LocalizedError {
    case badURL
    case requestFailed(statusCode: Int)
    case decodingFailed(Error)
    case noData
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "The URL was invalid. Please check the endpoint configuration."
        case .requestFailed(let statusCode):
            return "Request failed with status code \(statusCode)."
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data was returned from the server."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}
