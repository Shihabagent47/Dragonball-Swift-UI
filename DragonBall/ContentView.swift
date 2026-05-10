//
//  ContentView.swift
//  DragonBall
//

import SwiftUI

struct ContentView: View {

    @State private var showSplash = true

    var body: some View {
        ZStack {
            NavigationStack {
                CharacterListView()
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            }
        }
        .task {
            // Show splash for 2.2s then crossfade into the app
            try? await Task.sleep(for: .seconds(2.2))
            withAnimation(.easeInOut(duration: 0.5)) {
                showSplash = false
            }
        }
    }
}

#Preview {
    ContentView()
}
