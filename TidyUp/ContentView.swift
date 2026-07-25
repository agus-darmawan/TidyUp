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
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            TasksView()
                .tabItem { Label("Tasks", systemImage: "checkmark.circle.fill") }

            FinanceView()
                .tabItem { Label("Money", systemImage: "creditcard.fill") }

            MoreView()
                .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
        }
        .tint(AppTheme.Colors.accent)
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
