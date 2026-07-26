# TidyUp

[![iOS Build & Test](https://github.com/agus-darmawan/TidyUp/actions/workflows/ios-tests.yml/badge.svg)](https://github.com/agus-darmawan/TidyUp/actions/workflows/ios-tests.yml)

Offline personal assistant app — Tasks, Money (with Reimbursement),
Wardrobe, Journal, Calendar. No backend, no login. Swift 6, SwiftUI,
SwiftData, MVVM.

## Setup

1. Open `TidyUp.xcodeproj` in Xcode (iOS 18+, SwiftUI, SwiftData).
2. Add these Info.plist keys under the target's **Info** tab:
   - `Privacy - Photo Library Usage Description`
   - `Privacy - Camera Usage Description`
3. Build & run.

## Running Tests

This repo ships test files under `TidyUpTests/` but Xcode project files
can't be safely auto-generated, so add the test target once:

1. Xcode → File → New → Target → **Unit Testing Bundle** → name it `TidyUpTests`.
2. Drag the files from `TidyUpTests/` into that target.
3. `Cmd+U` to run locally, or push — GitHub Actions runs the same suite
   automatically (see `.github/workflows/ios-tests.yml`).

## Structure

```
TidyUp/
├── TidyUpApp.swift / ContentView.swift   Entry point, tab bar
├── Core/            Theme, DI, reusable components, services
└── Features/        Dashboard, Tasks, Wardrobe, Finance, Journal,
                      Calendar, Settings — each with its own
                      Models / Repositories / ViewModels / Views / Components
```

Repositories are protocol-based specifically so they're testable without
touching real data — see `DependencyContainer.preview` and
`TidyUpTests/TaskRepositoryTests.swift` for the in-memory pattern.

## Notes

- **Wardrobe**: no stock counts (every item has a unique code). Tap
  items into "today's outfit" then confirm once. Outerwear/Linens use
  a duration-based wash cycle instead of going dirty after one wear.
- **Reimbursement**: marking an expense as Reimbursement type debits the
  account immediately; a separate pending total tracks what the office
  still owes back. Flow: Pending → Submitted → Paid or Rejected.
- **Still not built**: Debt/Installment screens (models exist), backup/restore.
