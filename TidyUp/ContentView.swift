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
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
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
        .animation(AppTheme.Motion.snappy, value: selectedTab)
    }
}

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink { WardrobeView() } label: { Label("Wardrobe", systemImage: "tshirt.fill") }
                    NavigationLink { JournalView() } label: { Label("Journal", systemImage: "book.closed.fill") }
                    NavigationLink { CalendarView() } label: { Label("Calendar", systemImage: "calendar") }
                }
                Section {
                    NavigationLink { SettingsView() } label: { Label("Settings", systemImage: "gearshape.fill") }
                }
            }
            .navigationTitle("More")
        }
    }
}

#Preview {
    ContentView().environment(DependencyContainer.preview)
}
