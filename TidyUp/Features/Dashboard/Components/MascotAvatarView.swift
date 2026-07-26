//
//  MascotAvatarView.swift
//  TidyUp
//
//  A small, distinctive hand-drawn mascot face (not a generic SF Symbol
//  icon) — built entirely from SwiftUI shapes so it needs no external
//  image asset. Big round eyes, a clear upward smile, and blush cheeks
//  for a cheerful look (not a gloomy one).
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

            // Blush cheeks
            HStack(spacing: size * 0.42) {
                blush
                blush
            }
            .offset(y: size * 0.14)

            // Face
            VStack(spacing: size * 0.1) {
                HStack(spacing: size * 0.18) {
                    eye
                    eye
                }
                SmileShape()
                    .stroke(AppTheme.Colors.brandNavy, style: StrokeStyle(lineWidth: size * 0.055, lineCap: .round))
                    .frame(width: size * 0.34, height: size * 0.16)
            }
            .offset(y: -size * 0.02)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1.5))
    }

    private var eye: some View {
        Circle()
            .fill(AppTheme.Colors.brandNavy)
            .frame(width: size * 0.13, height: size * 0.13)
    }

    private var blush: some View {
        Circle()
            .fill(AppTheme.Colors.brandCoral.opacity(0.5))
            .frame(width: size * 0.14, height: size * 0.14)
    }
}

/// A guaranteed upward-curving smile (quadratic curve dipping toward the
/// bottom), instead of trimming an arbitrary shape's outline.
private struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background.ignoresSafeArea()
        MascotAvatarView(size: 80)
    }
}
