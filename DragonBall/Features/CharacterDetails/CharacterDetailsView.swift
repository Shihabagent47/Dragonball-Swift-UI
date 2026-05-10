//
//  CharacterDetailsView.swift
//  DragonBall
//

import SwiftUI

struct CharacterDetailsView: View {

    let character: Character
    @State private var viewModel: CharacterDetailsViewModel
    @State private var selectedTransformation: Transformation?

    init(character: Character) {
        self.character = character
        self._viewModel = State(initialValue: CharacterDetailsViewModel(characterId: character.id))
    }

    private var auraColor: Color { character.affiliation.color }

    var body: some View {
        ZStack {
            background

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else if let detail = viewModel.detail {
                contentView(detail)
            }
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await viewModel.load() }
        .sheet(item: $selectedTransformation) { transformation in
            TransformationSheetView(transformation: transformation, auraColor: auraColor)
        }
    }

    // MARK: - Content

    private func contentView(_ detail: CharacterDetail) -> some View {
        ScrollView {
            VStack(spacing: 0) {

                // ── Hero image ──────────────────────────────────────────
                heroSection(detail)

                // ── Info cards ──────────────────────────────────────────
                VStack(spacing: 20) {
                    statsSection(detail)

                    if let planet = detail.originPlanet {
                        planetSection(planet)
                    }

                    if !detail.transformations.isEmpty {
                        transformationsSection(detail.transformations)
                    }

                    descriptionSection(detail)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Hero Section

    private func heroSection(_ detail: CharacterDetail) -> some View {
        ZStack(alignment: .bottom) {
            // Character image
            CachedAsyncImage(url: URL(string: detail.image)) { img in
                img.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "person.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(auraColor.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 360)

            // Aura glow at feet
            Ellipse()
                .fill(auraColor.opacity(0.4))
                .frame(width: 200, height: 40)
                .blur(radius: 24)
                .offset(y: -8)

            // Bottom scrim into the page background
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.5),
                    .init(color: Color(red: 0.04, green: 0.04, blue: 0.12), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 360)

            // Name + affiliation overlay
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: character.affiliation.icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(character.affiliation.rawValue)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .textCase(.uppercase)
                        .tracking(1)
                }
                .foregroundStyle(auraColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background {
                    Capsule()
                        .fill(auraColor.opacity(0.2))
                        .overlay { Capsule().strokeBorder(auraColor.opacity(0.5), lineWidth: 0.8) }
                }

                Text(detail.name)
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: auraColor.opacity(0.7), radius: 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Stats Section

    private func statsSection(_ detail: CharacterDetail) -> some View {
        glassCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionHeader(icon: "bolt.fill", title: "Power Stats")

                HStack(spacing: 12) {
                    statBadge(label: "Race", value: detail.race)
                    statBadge(label: "Gender", value: detail.gender.rawValue)
                }

                KiBarView(
                    label: "Power Level",
                    value: detail.ki,
                    color: Color(red: 1.0, green: 0.8, blue: 0.2),
                    delay: 0.1
                )
                KiBarView(
                    label: "Max Ki",
                    value: detail.maxKi,
                    color: auraColor,
                    delay: 0.25
                )
            }
        }
    }

    // MARK: - Planet Section

    private func planetSection(_ planet: Planet) -> some View {
        glassCard {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(icon: "globe", title: "Origin Planet")

                HStack(spacing: 14) {
                    CachedAsyncImage(url: URL(string: planet.image)) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(auraColor.opacity(0.2))
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay { Circle().strokeBorder(auraColor.opacity(0.4), lineWidth: 1.5) }
                    .shadow(color: auraColor.opacity(0.3), radius: 10)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(planet.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        if planet.isDestroyed {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 11))
                                Text("Destroyed")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.red.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.red.opacity(0.15)))
                        }
                    }
                }

                Text(planet.description)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Transformations Section

    private func transformationsSection(_ transformations: [Transformation]) -> some View {
        glassCard {
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader(icon: "sparkles", title: "Transformations")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(transformations) { transformation in
                            Button {
                                selectedTransformation = transformation
                            } label: {
                                transformationCard(transformation)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func transformationCard(_ t: Transformation) -> some View {
        VStack(spacing: 8) {
            CachedAsyncImage(url: URL(string: t.image)) { img in
                img.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(auraColor.opacity(0.4))
            }
            .frame(width: 90, height: 110)
            .shadow(color: auraColor.opacity(0.4), radius: 10)

            Text(t.name)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 90)

            Text(t.ki)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(auraColor)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(auraColor.opacity(0.25), lineWidth: 1)
                }
        }
    }

    // MARK: - Description Section

    private func descriptionSection(_ detail: CharacterDetail) -> some View {
        glassCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(icon: "text.alignleft", title: "Biography")

                Text(detail.description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(5)
            }
        }
    }

    // MARK: - Reusable Components

    private func glassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(auraColor.opacity(0.05))
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), auraColor.opacity(0.3)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .shadow(color: auraColor.opacity(0.15), radius: 20, x: 0, y: 6)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 3)
    }

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(auraColor)
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
                .tracking(1.2)
        }
    }

    private func statBadge(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .textCase(.uppercase)
                .tracking(1)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.07))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 0.5)
                }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(.white.opacity(0.7))
            Text("Loading...")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Error

    private func errorView(_ error: NetworkError) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(error.errorDescription ?? "Unknown error")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                Task { await viewModel.load() }
            } label: {
                Text("Try Again")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color.white, in: Capsule())
            }
        }
    }

    // MARK: - Background

    private var background: some View {
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
    }
}

// MARK: - Transformation Sheet
struct TransformationSheetView: View {
    let transformation: Transformation
    let auraColor: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.12),
                    Color(red: 0.08, green: 0.04, blue: 0.18)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Handle
                Capsule()
                    .fill(.white.opacity(0.2))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)

                Spacer()

                // Aura glow
                Ellipse()
                    .fill(auraColor.opacity(0.35))
                    .frame(width: 200, height: 50)
                    .blur(radius: 30)

                // Image
                CachedAsyncImage(url: URL(string: transformation.image)) { img in
                    img.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "person.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(auraColor.opacity(0.4))
                }
                .frame(height: 280)
                .shadow(color: auraColor.opacity(0.6), radius: 30, x: 0, y: 10)

                Spacer()

                // Info
                VStack(spacing: 10) {
                    Text(transformation.name)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: auraColor.opacity(0.6), radius: 10)

                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(red: 1.0, green: 0.8, blue: 0.2))
                        Text(transformation.ki)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 1.0, green: 0.8, blue: 0.2))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(.white.opacity(0.08))
                            .overlay { Capsule().strokeBorder(auraColor.opacity(0.3), lineWidth: 1) }
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}


