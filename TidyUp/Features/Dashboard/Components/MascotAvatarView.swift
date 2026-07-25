//
//  MascotAvatarView.swift
//  TidyUp
//
//  Placeholder mascot avatar. Swap Image(systemName:) for a real asset
//  (Image("MascotFace")) once the mascot artwork is added to Assets.xcassets.
//

import SwiftUI

struct MascotAvatarView: View {
    var size: CGFloat = 44

    var body: some View {
        Circle()
            .fill(AppTheme.Colors.brandYellow.opacity(0.25))
            .frame(width: size, height: size)
            .overlay {
                // TODO: replace with Image("MascotFace") once the real mascot asset is added.
                Image(systemName: "bird.fill")
                    .font(.system(size: size * 0.45))
                    .foregroundStyle(AppTheme.Colors.brandCoral)
            }
    }
}
