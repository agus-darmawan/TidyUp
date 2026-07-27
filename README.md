# TidyUp

[![iOS Build](https://github.com/agus-darmawan/TidyUp/actions/workflows/ios-tests.yml/badge.svg)](https://github.com/agus-darmawan/TidyUp/actions/workflows/ios-tests.yml)

Offline personal assistant app — Tasks, Money (with Reimbursement),
Wardrobe, Journal, Calendar. No backend, no login. Swift 6, SwiftUI,
SwiftData, MVVM.

## Setup

1. Open `TidyUp.xcodeproj` in Xcode (iOS 18+, SwiftUI, SwiftData).
2. Add these Info.plist keys under the target's **Info** tab:
   - `Privacy - Photo Library Usage Description`
   - `Privacy - Camera Usage Description`
3. Build & run.

GitHub Actions builds the project on every push/PR (see
`.github/workflows/ios-tests.yml`) — no unit test target for now.

## Structure

```
TidyUp/
├── TidyUpApp.swift / ContentView.swift   Entry point, tab bar
├── Core/            Theme, DI, reusable components, services
└── Features/        Dashboard, Tasks, Wardrobe, Finance, Journal,
                      Calendar, Settings — each with its own
                      Models / Repositories / ViewModels / Views / Components
```

Repositories are protocol-based, so they're easy to swap for an
in-memory container in previews — see `DependencyContainer.preview`.

## Notes

- **Wardrobe**: no stock counts (every item has a unique code). Tap
  items into "today's outfit" then confirm once. Outerwear/Linens use
  a duration-based wash cycle instead of going dirty after one wear.
- **Reimbursement**: marking an expense as Reimbursement type debits the
  account immediately; a separate pending total tracks what the office
  still owes back. Flow: Pending → Submitted → Paid or Rejected.
- **Backup/Restore**: exports everything — Tasks, Wardrobe, Journal, Money,
  Calendar, plus every referenced photo — into one self-contained JSON
  file (Settings → Backup & Restore). Restoring replaces all current data.