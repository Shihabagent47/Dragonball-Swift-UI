//
//  SplashScreenView.swift
//  DragonBall
//

import SwiftUI

struct SplashScreenView: View {

    @State private var appeared = false
    @State private var orbsVisible = false
    @State private var titleScale: CGFloat = 0.7
    @State private var titleOpacity: CGFloat = 0
    @State private var subtitleOpacity: CGFloat = 0
    @State private var glowRadius: CGFloat = 0

    var body: some View {
        ZStack {
            // ── Background ─────────────────────────────────────────────
            Color(red: 0.04, green: 0.04, blue: 0.12)
                .ignoresSafeArea()

            // ── Animated background orbs ───────────────────────────────
            Circle()
                .fill(Color(red: 0.2, green: 0.4, blue: 1.0).opacity(0.18))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: -130, y: -260)
                .opacity(orbsVisible ? 1 : 0)
                .animation(.easeOut(duration: 1.4), value: orbsVisible)

            Circle()
                .fill(Color(red: 0.9, green: 0.3, blue: 0.1).opacity(0.14))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(x: 140, y: 300)
                .opacity(orbsVisible ? 1 : 0)
                .animation(.easeOut(duration: 1.4).delay(0.2), value: orbsVisible)

            Circle()
                .fill(Color(red: 0.6, green: 0.1, blue: 0.9).opacity(0.10))
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(x: 100, y: -350)
                .opacity(orbsVisible ? 1 : 0)
                .animation(.easeOut(duration: 1.4).delay(0.4), value: orbsVisible)

            // ── Content ────────────────────────────────────────────────
            VStack(spacing: 0) {

                // Dragon Ball sphere icon
                ZStack {
                    // Outer glow pulse
                    Circle()
                        .fill(Color(red: 1.0, green: 0.7, blue: 0.1).opacity(0.3))
                        .frame(width: 120, height: 120)
                        .blur(radius: glowRadius)
                        .animation(
                            .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                            value: glowRadius
                        )

                    // Sphere
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.2),
                                    Color(red: 1.0, green: 0.55, blue: 0.05)
                                ],
                                center: .topLeading,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 90, height: 90)
                        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.8), radius: 20)

                    // Star dots on the sphere
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(Color(red: 0.9, green: 0.1, blue: 0.1))
                            .frame(width: 10, height: 10)
                            .offset(starOffset(index: i))
                    }
                }
                .scaleEffect(appeared ? 1 : 0.3)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1), value: appeared)
                .padding(.bottom, 28)

                // App title
                Text("DRAGON BALL")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.85, blue: 0.3),
                                Color(red: 1.0, green: 0.55, blue: 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .tracking(4)
                    .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.1).opacity(0.6), radius: 16)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: titleScale)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: titleOpacity)
                    .padding(.bottom, 10)

                // Subtitle
                Text("Universe 7 Roster")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.45))
                    .tracking(3)
                    .opacity(subtitleOpacity)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: subtitleOpacity)
            }
        }
        .onAppear {
            appeared = true
            orbsVisible = true
            titleScale = 1.0
            titleOpacity = 1.0
            subtitleOpacity = 1.0
            glowRadius = 30
        }
    }

    // Position the 4 star dots on the sphere
    private func starOffset(index: Int) -> CGSize {
        let positions: [CGSize] = [
            CGSize(width: -12, height: -14),
            CGSize(width: 14, height: -8),
            CGSize(width: -6, height: 12),
            CGSize(width: 16, height: 14)
        ]
        return positions[index]
    }
}

#Preview {
    SplashScreenView()
}
