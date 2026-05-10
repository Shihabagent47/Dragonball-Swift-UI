//
//  CharacterModel.swift
//  DragonBall
//

import Foundation

// MARK: - List models

struct CharacterPage: Codable {
    let characters: [Character]
    let meta: PageMeta
    let links: PageLinks

    enum CodingKeys: String, CodingKey {
        case characters = "items"
        case meta
        case links
    }
}

struct Character: Codable {
    let id: Int
    let name: String
    let ki: String
    let maxKi: String
    let race: String
    let gender: Gender
    let description: String
    let image: String
    let affiliation: Affiliation
    let deletedAt: Date?
}

// MARK: - Detail models

/// Full character response from the /characters/:id endpoint.
/// Extends the base character fields with planet and transformation data.
struct CharacterDetail: Codable {
    let id: Int
    let name: String
    let ki: String
    let maxKi: String
    let race: String
    let gender: Gender
    let description: String
    let image: String
    let affiliation: Affiliation
    let deletedAt: Date?
    let originPlanet: Planet?
    let transformations: [Transformation]
}

struct Planet: Codable {
    let id: Int
    let name: String
    let isDestroyed: Bool
    let description: String
    let image: String
    let deletedAt: Date?
}

struct Transformation: Codable, Identifiable {
    let id: Int
    let name: String
    let image: String
    let ki: String
    let deletedAt: Date?
}

// MARK: - Shared enums

enum Affiliation: String, Codable {
    case armyOfFrieza = "Army of Frieza"
    case freelancer = "Freelancer"
    case zFighter = "Z Fighter"
    case namekian = "namekian"
    case villain = "Villain"
    case other = "Other"
    case unknown = "Unknown"

    // Fallback for any future values the API adds
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Affiliation(rawValue: raw) ?? .unknown
    }
}

enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
}

// MARK: - Pagination

struct PageLinks: Codable {
    let first: String
    let previous: String?
    let next: String?
    let last: String
}

struct PageMeta: Codable {
    let totalItems: Int
    let itemCount: Int
    let itemsPerPage: Int
    let totalPages: Int
    let currentPage: Int
}
