//
//  MascotAvatarView.swift
//  TidyUp
//
//  A small, distinctive hand-drawn mascot face (not a generic SF Symbol
//  icon) — built entirely from SwiftUI shapes so it needs no external
//  image asset. Friendly rounded face, two eyes, a little smile.
//

import SwiftUI

struct MascotAvatarView: View {
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.Colors.brandYellow, AppTheme.Colors.brandCoral],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            // Face
            VStack(spacing: size * 0.08) {
                HStack(spacing: size * 0.16) {
                    eye
                    eye
                }
                smile
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1.5))
    }

    private var eye: some View {
        Circle()
            .fill(AppTheme.Colors.brandNavy)
            .frame(width: size * 0.11, height: size * 0.11)
    }

    private var smile: some View {
        Capsule()
            .trim(from: 0.55, to: 0.95)
            .stroke(AppTheme.Colors.brandNavy, style: StrokeStyle(lineWidth: size * 0.05, lineCap: .round))
            .frame(width: size * 0.4, height: size * 0.28)
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background.ignoresSafeArea()
        MascotAvatarView(size: 80)
    }
}
