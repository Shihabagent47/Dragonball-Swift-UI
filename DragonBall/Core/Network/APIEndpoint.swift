//
//  APIEndpoint.swift
//  DragonBall
//

import Foundation

enum APIEndpoint {
    private static let baseURL = "https://dragonball-api.com/api"

    case characters(page: Int, limit: Int)
    case characterDetail(id: Int)

    var url: URL? {
        switch self {
        case .characters(let page, let limit):
            var components = URLComponents(string: "\(APIEndpoint.baseURL)/characters")
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]
            return components?.url

        case .characterDetail(let id):
            return URL(string: "\(APIEndpoint.baseURL)/characters/\(id)")
        }
    }
}
