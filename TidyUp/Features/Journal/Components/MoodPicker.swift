//
//  MoodPicker.swift
//  TidyUp
//

import SwiftUI

struct MoodPicker: View {
    @Binding var selection: MoodType

    var body: some View {
        HStack {
            ForEach(MoodType.allCases) { mood in
                Button { selection = mood } label: {
                    VStack(spacing: 4) {
                        Text(mood.emoji).font(.title)
                        Text(mood.label).font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .fill(selection == mood ? AppTheme.Colors.forMood(mood).opacity(0.2) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .foregroundStyle(selection == mood ? AppTheme.Colors.forMood(mood) : AppTheme.Colors.secondaryText)
            }
        }
    }
}

struct JournalCardView: View {
    let entry: JournalEntry

    var body: some View {
        PACard {
            HStack {
                Text(entry.mood.emoji).font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.date.formatted(.medium)).font(.system(size: 11)).foregroundStyle(AppTheme.Colors.secondaryText)
                    Text(entry.reflection.isEmpty ? "No reflection written" : entry.reflection)
                        .font(.system(size: 14)).lineLimit(2)
                }
                Spacer()
            }
        }
    }
}
