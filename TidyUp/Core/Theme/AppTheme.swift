//
//  AppTheme.swift
//  TidyUp
//
//  iOS-native light-blue tone (matches the reference mockups): soft
//  blue-gray background, white cards, vivid blue as the single primary
//  accent used consistently for buttons, badges, and highlights.
//

import SwiftUI
import UIKit

enum AppTheme {

    enum Colors {
        // Brand accents — fixed, vivid, same across Light/Dark Mode.
        static let brandMint = Color(hex: "#3B82F6")      // primary accent — iOS-style blue
        static let brandCoral = Color(hex: "#EF4444")      // danger / expense
        static let brandYellow = Color(hex: "#F59E0B")     // warning / highlight
        static let brandPurple = Color(hex: "#8B5CF6")     // reimbursement
        static let brandGreen = Color(hex: "#22C55E")      // success / income (separate from accent blue)
        static let brandNavy = Color(hex: "#0F172A")       // dark text / dark-mode background base
        static let brandGray = Color(hex: "#94A3B8")

        static let accent = brandMint

        // Adaptive — automatically follows system Light/Dark Mode.
        static let background = Color(light: "#F2F5FA", dark: "#0B1220")
        static let surface = Color(light: "#FFFFFF", dark: "#151E2E")
        static let surfaceElevated = Color(light: "#EAF1FD", dark: "#1D2A3D")

        static let primaryText = Color(light: "#0F172A", dark: "#F1F5F9")
        static let secondaryText = Color(light: "#64748B", dark: "#94A3B8")
        static let tertiaryText = secondaryText.opacity(0.6)

        static let success = brandGreen
        static let warning = brandYellow
        static let danger = brandCoral
        static let income = brandGreen
        static let expense = brandCoral
        static let reimburse = brandPurple

        static func forPriority(_ priority: TaskPriority) -> Color {
            switch priority {
            case .low: return brandGreen
            case .medium: return brandYellow
            case .high: return brandCoral
            }
        }

        static func forMood(_ mood: MoodType) -> Color {
            switch mood {
            case .great: return brandGreen
            case .good: return brandMint
            case .neutral: return brandGray
            case .bad: return brandYellow
            case .terrible: return brandCoral
            }
        }

        static func forLaundryStatus(_ status: LaundryStatus) -> Color {
            switch status {
            case .clean: return brandGreen
            case .dirty: return brandCoral
            }
        }

        /// Returns whichever of white or dark navy has the higher WCAG
        /// contrast ratio against the given background color, so tag/
        /// priority/status badges stay legible no matter how light,
        /// dark, or saturated the color is.
        static func contrastingText(on color: Color) -> Color {
            let bgLuminance = UIColor(color).relativeLuminance
            let whiteContrast = (1.0 + 0.05) / (bgLuminance + 0.05)
            let navyLuminance = UIColor(brandNavy).relativeLuminance
            let navyContrast = (bgLuminance + 0.05) / (navyLuminance + 0.05)
            return whiteContrast >= navyContrast ? .white : brandNavy
        }

        /// Distinct gradients for the Money "wallet" cards, cycling by index
        /// so each account reads as visually distinct at a glance.
        static func walletGradient(for index: Int) -> LinearGradient {
            let palettes: [[Color]] = [
                [Color(hex: "#3B82F6"), Color(hex: "#1E40AF")],
                [Color(hex: "#22C55E"), Color(hex: "#15803D")],
                [Color(hex: "#8B5CF6"), Color(hex: "#5B21B6")],
                [Color(hex: "#0F172A"), Color(hex: "#334155")],
                [Color(hex: "#F59E0B"), Color(hex: "#B45309")]
            ]
            let colors = palettes[index % palettes.count]
            return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 22
        static let pill: CGFloat = 999
    }

    enum Motion {
        static let snappy = Animation.snappy(duration: 0.35)
        static let bouncy = Animation.bouncy(duration: 0.4)
        static let quick = Animation.easeOut(duration: 0.2)
    }

    enum Typography {
        // Full semantic scale, all Dynamic-Type-aware (scales with the
        // user's accessibility text size setting, per HIG).
        static let display = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title1 = Font.system(.title, design: .rounded).weight(.bold)
        static let title2 = Font.system(.title2, design: .rounded).weight(.semibold)
        static let title3 = Font.system(.title3, design: .rounded).weight(.semibold)
        static let headline = Font.system(.headline, design: .default).weight(.semibold)
        static let body = Font.system(.body)
        static let callout = Font.system(.callout)
        static let subheadline = Font.system(.subheadline)
        static let footnote = Font.system(.footnote)
        static let caption = Font.system(.caption)
        static let caption2 = Font.system(.caption2)
        static let monospacedAmount = Font.system(.title2, design: .rounded).weight(.bold)
        static let monospacedAmountLarge = Font.system(.largeTitle, design: .rounded).weight(.bold)

        // Legacy aliases kept for existing call sites.
        static let largeTitle = display
        static let title = title2
    }
}
