# TidyUp

Fully offline personal assistant app — Tasks, Money (with full
Reimbursement flow), Wardrobe, Journal, and a lightweight Calendar.
No backend, no login, no network calls. Built with Swift 6, SwiftUI,
SwiftData, MVVM + Clean Architecture.

## How to open this in Xcode

This repo contains **source files only**. To use it:

1. Open your existing `TidyUp.xcodeproj` (or create a new iOS App
   project named `TidyUp`, SwiftUI interface, SwiftData storage,
   minimum deployment iOS 18+).
2. Drag the `TidyUp/` folder from this repo into your Xcode project
   navigator ("Copy items if needed", "Create groups").
3. If Xcode's own `ContentView.swift` / `TidyUpApp.swift` / `Item.swift`
   still exist in your project, delete them — this repo's versions
   replace them.
4. Add these Info.plist privacy keys via your target's **Info** tab
   (Custom iOS Target Properties):
   - `Privacy - Photo Library Usage Description`
   - `Privacy - Camera Usage Description`
5. Build & run.

## Architecture

```
TidyUp/
├── TidyUpApp.swift          Entry point — SwiftData schema + DI container
├── ContentView.swift         Root tab bar (Home / Tasks / Money / More)
├── Core/
│   ├── DI/                  DependencyContainer (composition root)
│   ├── Theme/                AppTheme — bright, fresh color palette
│   ├── Components/            Reusable views (PACard, PATagChip, ...)
│   ├── Extensions/             Color+Hex, Date, Currency helpers
│   └── Services/                ImageStorage, Notification, PDFExport
└── Features/
    ├── Dashboard/            Home tab — Task/Money/Wardrobe overview
    ├── Tasks/                Hierarchical tasks with subtasks, reminders,
    │                         recurrence, priority, tags
    ├── Wardrobe/             No stock counts — every item has a unique
    │                         code. One-tap "wear" from the list. Linens
    │                         (towels/bedsheets) track replacement cycles.
    ├── Finance/              Accounts, transactions, debts, installments,
    │                         and a full Reimbursement flow with PDF export
    ├── Journal/              Mood-tracked daily reflections
    ├── Calendar/              Lightweight upcoming-events agenda
    │                         (secondary feature, not a main tab)
    └── Settings/              Category management, app info
```

## Design notes

- **Color palette**: bright and fresh (mint `#2EC4B6`, coral, sunny
  yellow), adaptive between Light/Dark Mode. Every badge/tag/priority
  pill uses `AppTheme.Colors.contrastingText(on:)` to guarantee
  readable text regardless of how light or saturated the background is.
- **Main features are Tasks and Money** — Calendar is intentionally
  a secondary, lightweight aggregator tucked under "More", not a
  headline tab.
- **Wardrobe v2**: no stock counts (every physical item is unique —
  its own `itemCode`), one-tap "I'm wearing this" straight from the
  list row (no need to search + open detail first), and a `.linens`
  category for towels/bedsheets with replacement-interval tracking
  and a local notification once it's due.
- **Reimbursement flow**: marking an expense reimbursable still debits
  the real account immediately (the money left your pocket), while a
  separate `pendingReimburseTotal` tracks what's still owed back.
  Reimbursable transactions require both a receipt photo and an item
  photo before they're "report-ready". `PDFExportService` builds a
  paginated PDF embedding both photos per line item, ready to submit.

## Still to do (next commits)

- Debt/Installment screens (models exist, UI not built yet)
- Backup/restore (local JSON export/import)
- Real mascot artwork (currently a placeholder SF Symbol in
  `MascotAvatarView`)
- Unit tests (every repository is protocol-based specifically to
  support this — see `DependencyContainer.preview` for the in-memory
  pattern to reuse)
