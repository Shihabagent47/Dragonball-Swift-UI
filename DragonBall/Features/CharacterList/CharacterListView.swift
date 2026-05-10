//
//  CharacterListView.swift
//  DragonBall
//

import SwiftUI

struct CharacterListView: View {

    @State private var viewModel = CharacterListViewModel()
    @State private var searchQuery = ""

    // Filters loaded characters client-side by name or race
    private var filteredCharacters: [Character] {
        guard !searchQuery.isEmpty else { return viewModel.characters }
        return viewModel.characters.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.race.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    var body: some View {
        ZStack {
            background

            Group {
                if viewModel.characters.isEmpty && viewModel.isLoading {
                    loadingView
                } else if viewModel.characters.isEmpty, let error = viewModel.error {
                    errorView(error)
                } else if viewModel.characters.isEmpty {
                    emptyState
                } else {
                    characterList
                }
            }
        }
        .navigationTitle("Characters")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(
            text: $searchQuery,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search by name or race"
        )
        .task {
            await viewModel.loadInitial()
        }
    }

    // MARK: - Character List

    private var characterList: some View {
        ScrollView {
            LazyVStack(spacing: 60) {
                ForEach(Array(filteredCharacters.enumerated()), id: \.element.id) { index, character in
                    NavigationLink(destination: CharacterDetailsView(character: character)) {
                        CharacterItemCardView(character: character)
                    }
                    .buttonStyle(CardButtonStyle())
                    .onAppear {
                        // Only trigger pagination when not searching
                        guard searchQuery.isEmpty else { return }
                        let triggerIndex = viewModel.characters.count - 3
                        if index >= triggerIndex {
                            Task { await viewModel.loadNextPage() }
                        }
                    }
                }

                // Show no-results state when searching
                if !searchQuery.isEmpty && filteredCharacters.isEmpty {
                    searchEmptyState
                }

                if searchQuery.isEmpty && viewModel.hasMorePages {
                    paginationFooter
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Search Empty State

    private var searchEmptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.2))
            Text("No results for \"\(searchQuery)\"")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Pagination Footer

    private var paginationFooter: some View {
        HStack(spacing: 10) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white.opacity(0.6))
                Text("Loading more...")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.2))

            Text("No Characters Found")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            Text("Pull down to refresh")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(.white.opacity(0.7))
            Text("Powering up...")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Error View

    private func errorView(_ error: NetworkError) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(error.errorDescription ?? "Unknown error")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                Task { await viewModel.refresh() }
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

            Circle()
                .fill(Color(red: 0.2, green: 0.4, blue: 1.0).opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: -120, y: -280)

            Circle()
                .fill(Color(red: 0.9, green: 0.3, blue: 0.2).opacity(0.08))
                .frame(width: 240, height: 240)
                .blur(radius: 60)
                .offset(x: 140, y: 320)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CharacterListView()
    }
}
