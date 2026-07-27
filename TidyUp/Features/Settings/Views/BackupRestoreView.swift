//
//  BackupRestoreView.swift
//  TidyUp
//
//  Export everything to one JSON file (photos included) you can save to
//  Files/AirDrop/iCloud Drive, and restore from it later — the "if it
//  gets deleted, I have a backup" safety net.
//

import SwiftUI
import UniformTypeIdentifiers

struct BackupRestoreView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var showingShareSheet = false
    @State private var showingImporter = false
    @State private var showingRestoreConfirm = false
    @State private var pendingRestoreURL: URL?
    @State private var showingRestoreDone = false
    @State private var lastExportedURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section {
                Text("Exports every Task, Wardrobe item, Journal entry, Account, Transaction, Debt, Installment, and Calendar event — including all photos — into a single file.")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                Button {
                    exportBackup()
                } label: {
                    Label("Export Backup", systemImage: "square.and.arrow.up")
                }
            } header: {
                Text("Backup")
            }

            Section {
                Button {
                    showingImporter = true
                } label: {
                    Label("Restore from Backup", systemImage: "square.and.arrow.down")
                }
            } header: {
                Text("Restore")
            } footer: {
                Text("Restoring replaces all current data with what's in the backup file. This can't be undone — make sure you're restoring the right file.")
            }

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(AppTheme.Colors.danger).font(.system(size: 13))
                }
            }
        }
        .navigationTitle("Backup & Restore")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let lastExportedURL {
                ShareSheet(activityItems: [lastExportedURL])
            }
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                pendingRestoreURL = url
                showingRestoreConfirm = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .confirmationDialog(
            "Replace all current data with this backup?",
            isPresented: $showingRestoreConfirm,
            titleVisibility: .visible
        ) {
            Button("Restore", role: .destructive) { restoreBackup() }
            Button("Cancel", role: .cancel) { pendingRestoreURL = nil }
        }
        .alert("Restore Complete", isPresented: $showingRestoreDone) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your data has been restored from the backup.")
        }
    }

    private func exportBackup() {
        do {
            lastExportedURL = try container.backupService.exportBackup()
            showingShareSheet = true
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
        }
    }

    private func restoreBackup() {
        guard let url = pendingRestoreURL else { return }
        do {
            // Security-scoped access is required for files picked via fileImporter.
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            try container.backupService.importBackup(from: url)
            showingRestoreDone = true
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
        pendingRestoreURL = nil
    }
}

#Preview {
    NavigationStack { BackupRestoreView() }.environment(DependencyContainer.preview)
}
