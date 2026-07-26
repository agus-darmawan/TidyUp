//
//  ContentView.swift
//  TidyUp
//
//  Root tab bar. Home, Tasks, and Money are the three primary tabs —
//  Wardrobe, Journal, Calendar, and Settings live under "More" so Task
//  and Money stay the headline features (not Calendar).
//

import SwiftUI

struct ContentView: View {
    @State private var tabRouter = TabRouter()

    var body: some View {
        TabView(selection: Binding(
            get: { tabRouter.selectedTab },
            set: { tabRouter.selectedTab = $0 }
        )) {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            TasksView()
                .tabItem { Label("Tasks", systemImage: "checkmark.circle.fill") }
                .tag(1)

            FinanceView()
                .tabItem { Label("Money", systemImage: "creditcard.fill") }
                .tag(2)

            MoreView()
                .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
                .tag(3)
        }
        .tint(AppTheme.Colors.accent)
        .animation(AppTheme.Motion.snappy, value: tabRouter.selectedTab)
        .environment(tabRouter)
    }
}

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink { WardrobeView() } label: {
                        SettingsIconRow(icon: "tshirt.fill", tint: AppTheme.Colors.warning, title: "Wardrobe")
                    }
                    NavigationLink { JournalView() } label: {
                        SettingsIconRow(icon: "book.closed.fill", tint: AppTheme.Colors.reimburse, title: "Journal")
                    }
                    NavigationLink { CalendarView() } label: {
                        SettingsIconRow(icon: "calendar", tint: AppTheme.Colors.brandGreen, title: "Calendar")
                    }
                }
                Section {
                    NavigationLink { SettingsView() } label: {
                        SettingsIconRow(icon: "gearshape.fill", tint: AppTheme.Colors.brandGray, title: "Settings")
                    }
                }
            }
            .navigationTitle("More")
        }
    }
}

#Preview {
    ContentView().environment(DependencyContainer.preview)
}
