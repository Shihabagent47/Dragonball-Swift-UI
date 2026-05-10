//
//  CharacterItemCardView.swift
//  DragonBall
//

import SwiftUI
import Foundation

// MARK: - Affiliation Badge Color
extension Affiliation {
    var color: Color {
        switch self {
        case .zFighter:     return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .namekian:     return Color(red: 0.2, green: 0.85, blue: 0.4)
        case .armyOfFrieza: return Color.purple
        case .freelancer:   return Color.orange
        case .villain:      return Color(red: 0.8, green: 0.1, blue: 0.1)
        case .other:        return Color.blue
        case .unknown:      return Color.brown
        }
    }

    var icon: String {
        switch self {
        case .zFighter:     return "shield.fill"
        case .namekian:     return "leaf.fill"
        case .armyOfFrieza: return "flame.fill"
        case .freelancer:   return "person.fill"
        case .villain:      return "bolt.fill"
        case .other:        return "person.fill"
        case .unknown:      return "person.fill"
        }
    }
}

// MARK: - Ki Parser

/// Parses the API's wildly inconsistent Ki strings into a Double.
/// Handles: European dots ("60.000.000"), US commas ("280,000,000"),
/// named units ("8 Billion", "969 Googolplex"), "0", and "unknown".
private func parseKi(_ raw: String) -> Double? {
    let s = raw.trimmingCharacters(in: .whitespaces).lowercased()
    guard s != "unknown", s != "" else { return nil }

    // Named unit multipliers (case-insensitive, log10 scale friendly)
    let units: [(suffix: String, multiplier: Double)] = [
        ("googolplex", 1e100),   // beyond septillion, symbolic cap
        ("googol",     1e100),
        ("septillion", 1e24),
        ("sextillion", 1e21),
        ("quintillion",1e18),
        ("quadrillion",1e15),
        ("trillion",   1e12),
        ("billion",    1e9),
        ("million",    1e6),
        ("thousand",   1e3)
    ]

    for unit in units {
        if s.contains(unit.suffix) {
            let numberPart = s.replacingOccurrences(of: unit.suffix, with: "")
                              .trimmingCharacters(in: .whitespaces)
            if let num = Double(numberPart) {
                return num * unit.multiplier
            }
        }
    }

    // Numeric-only: strip separators.
    // European style uses dots as thousands separators (e.g. "60.000.000")
    // US style uses commas (e.g. "280,000,000")
    // Detect by counting separator occurrences and position of last one.
    var cleaned = s

    // If dots appear as thousands separators (no decimal context), remove them.
    // Heuristic: multiple dots, or dot not followed by exactly 1-2 digits at end.
    let dotCount = cleaned.filter { $0 == "." }.count
    let commaCount = cleaned.filter { $0 == "," }.count

    if dotCount > 0 && commaCount == 0 {
        // Could be European thousands (60.000.000) or a decimal (3.2)
        // European: dot always followed by exactly 3 digits
        let parts = cleaned.components(separatedBy: ".")
        let isEuropeanThousands = parts.dropFirst().allSatisfy { $0.count == 3 }
        if isEuropeanThousands {
            cleaned = cleaned.replacingOccurrences(of: ".", with: "")
        }
        // Otherwise leave as-is (it's a real decimal like "3.2")
    } else if commaCount > 0 {
        // US thousands separator
        cleaned = cleaned.replacingOccurrences(of: ",", with: "")
    }

    return Double(cleaned)
}

/// Normalises a Ki value to a 0–1 fill fraction using a log10 scale.
/// Max reference point: Zeno's 500 Septillion (≈ 5×10^26).
private func kiFillFraction(_ raw: String) -> CGFloat {
    guard let value = parseKi(raw), value > 0 else {
        return raw.lowercased() == "unknown" ? 0.05 : 0.0
    }
    let logValue = log10(value)
    // Scale: 0 (log10(1)=0) to ~29 (log10(1e29), capped at Googolplex as 1.0)
    let logMin: Double = 0
    let logMax: Double = 29
    return CGFloat(max(0, min(1, (logValue - logMin) / (logMax - logMin))))
}

// MARK: - Ki Bar Component
struct KiBarView: View {
    let label: String
    let value: String
    let color: Color
    let delay: Double

    @State private var animateBar = false

    private var fillFraction: CGFloat {
        kiFillFraction(value)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1.2)
                Spacer()
                Text(value)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(color)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.08))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            colors: [color.opacity(0.8), color],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: animateBar ? geo.size.width * fillFraction : 0, height: 6)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(delay), value: animateBar)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.4))
                        .frame(width: animateBar ? geo.size.width * fillFraction : 0, height: 6)
                        .blur(radius: 4)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(delay), value: animateBar)
                }
            }
            .frame(height: 6)
        }
        .onAppear { animateBar = true }
    }
}

// MARK: - Stat Pill
struct StatPillView: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            Text(text)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(.white.opacity(0.12))
                .overlay {
                    Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                }
        }
    }
}

// MARK: - Main Card

/// Height of the image above the card top edge.
private let imageHeight: CGFloat = 260
/// How much of the image sits above the card.
private let imageOverhang: CGFloat = 160

struct CharacterItemCardView: View {

    let character: Character

    @State private var appeared = false

    private var auraColor: Color { character.affiliation.color }

    var body: some View {
        ZStack(alignment: .top) {
            // ── Glass info card — pushed down to leave room for image ──
            infoCard
                .padding(.top, imageOverhang)

            // ── Character image — anchored at top, hangs above card ───
            characterImage
        }
        .scaleEffect(appeared ? 1 : 0.93)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: appeared)
        .onAppear { appeared = true }
    }

    // MARK: - Character Image

    private var characterImage: some View {
        ZStack(alignment: .bottom) {
            // Aura glow under the feet
            Ellipse()
                .fill(auraColor.opacity(0.4))
                .frame(width: 160, height: 30)
                .blur(radius: 20)
                .offset(y: -4)

            CachedAsyncImage(url: URL(string: character.image)) { img in
                img.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "person.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(auraColor.opacity(0.5))
            }
            .frame(height: imageHeight)
            .shadow(color: auraColor.opacity(0.6), radius: 20, x: 0, y: 8)
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 4)
        }
        // zIndex ensures image always renders above the card
        .zIndex(1)
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Top padding inside the card so text starts below the image
            let internalImageSpace = imageHeight - imageOverhang
            Spacer().frame(height: internalImageSpace + 12)

            // Affiliation + stat pills
            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: character.affiliation.icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(character.affiliation.rawValue)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .textCase(.uppercase)
                        .tracking(0.8)
                }
                .foregroundStyle(auraColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule()
                        .fill(auraColor.opacity(0.18))
                        .overlay {
                            Capsule().strokeBorder(auraColor.opacity(0.5), lineWidth: 0.8)
                        }
                }

                StatPillView(icon: "person.and.background.dotted", text: character.race)
                StatPillView(
                    icon: character.gender == .female ? "figure.stand.dress" : "figure.stand",
                    text: character.gender.rawValue
                )
            }
            .padding(.bottom, 10)

            // Name
            Text(character.name)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .shadow(color: auraColor.opacity(0.5), radius: 10)
                .padding(.bottom, 16)

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 0.5)
                .padding(.bottom, 14)

            // Ki bars
            VStack(spacing: 10) {
                KiBarView(label: "Power Level", value: character.ki,
                          color: Color(red: 1.0, green: 0.8, blue: 0.2), delay: 0.2)
                KiBarView(label: "Max Ki", value: character.maxKi,
                          color: auraColor, delay: 0.4)
            }
            .padding(.bottom, 14)

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 0.5)
                .padding(.bottom, 12)

            // Description
            Text(character.description)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
                .lineLimit(3)
                .lineSpacing(4)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(
                        colors: [auraColor.opacity(0.1), Color.clear],
                        startPoint: .top, endPoint: .bottom
                    ))

                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                auraColor.opacity(0.4),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .shadow(color: auraColor.opacity(0.25), radius: 28, x: 0, y: 10)
        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Button Style for NavigationLink press animation

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.04, blue: 0.12),
                Color(red: 0.08, green: 0.04, blue: 0.18),
                Color(red: 0.04, green: 0.08, blue: 0.16)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        Circle()
            .fill(Color(red: 0.2, green: 0.4, blue: 1.0).opacity(0.15))
            .frame(width: 300, height: 300)
            .blur(radius: 60)
            .offset(x: -100, y: -200)

        ScrollView {
            VStack(spacing: 40) {
                CharacterItemCardView(character: Character(
                    id: 1,
                    name: "Goku",
                    ki: "60,000,000",
                    maxKi: "90 Septillion",
                    race: "Saiyan",
                    gender: .male,
                    description: "The main protagonist of the Dragon Ball series. A cheerful Saiyan warrior raised on Earth who strives to be the strongest fighter in the universe.",
                    image: "https://dragonball-api.com/characters/goku_normal.webp",
                    affiliation: .zFighter,
                    deletedAt: nil
                ))
                CharacterItemCardView(character: Character(
                    id: 2,
                    name: "Vegeta",
                    ki: "54,000,000",
                    maxKi: "19.84 Septillion",
                    race: "Saiyan",
                    gender: .male,
                    description: "The prince of the fallen Saiyan race and one of the most prominent characters in the Dragon Ball series.",
                    image: "https://dragonball-api.com/characters/vegeta_normal.webp",
                    affiliation: .zFighter,
                    deletedAt: nil
                ))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
    }
}
