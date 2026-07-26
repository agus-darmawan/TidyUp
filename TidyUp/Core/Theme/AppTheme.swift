//
//  AppTheme.swift
//  TidyUp
//
//  Single source of truth for visual styling. Bright & fresh palette
//  (mint/coral/sunny yellow) with an adaptive Light/Dark background,
//  plus a contrast helper so badges/tags never wash out regardless of
//  which color or mode they sit on.
//

import SwiftUI
import UIKit

enum AppTheme {

    enum Colors {
        // Brand accents — fixed, vivid, same across Light/Dark Mode.
        static let brandMint = Color(hex: "#2E86DE")     // primary accent, ocean blue
        static let brandCoral = Color(hex: "#FF6B6B")     // secondary accent / danger / expense
        static let brandYellow = Color(hex: "#FFB020")    // highlight / warning
        static let brandPurple = Color(hex: "#7C6FDB")    // reimbursement
        static let brandNavy = Color(hex: "#101822")      // dark text / dark-mode background base
        static let brandGray = Color(hex: "#8A98A0")

        static let accent = brandMint

        // Adaptive — automatically follows system Light/Dark Mode.
        static let background = Color(light: "#F5F9FC", dark: "#101822")
        static let surface = Color(light: "#FFFFFF", dark: "#1B2530")
        static let surfaceElevated = Color(light: "#EAF2FA", dark: "#243040")

        static let primaryText = Color(light: "#101822", dark: "#F5F7FA")
        static let secondaryText = Color(light: "#5E7180", dark: "#8A98A0")
        static let tertiaryText = secondaryText.opacity(0.6)

        static let success = brandMint
        static let warning = brandYellow
        static let danger = brandCoral
        static let income = brandMint
        static let expense = brandCoral
        static let reimburse = brandPurple

        static func forPriority(_ priority: TaskPriority) -> Color {
            switch priority {
            case .low: return brandMint
            case .medium: return brandYellow
            case .high: return brandCoral
            }
        }

        static func forMood(_ mood: MoodType) -> Color {
            switch mood {
            case .great: return brandMint
            case .good: return Color(hex: "#8FE3D1")
            case .neutral: return brandGray
            case .bad: return brandYellow
            case .terrible: return brandCoral
            }
        }

        static func forLaundryStatus(_ status: LaundryStatus) -> Color {
            switch status {
            case .clean: return brandMint
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
        static let pill: CGFloat = 999
    }

    enum Typography {
        static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = Font.system(.title2, design: .rounded).weight(.semibold)
        static let headline = Font.headline
        static let body = Font.body
        static let subheadline = Font.subheadline
        static let caption = Font.caption
        static let monospacedAmount = Font.system(.title3, design: .rounded).weight(.semibold)
    }
}
