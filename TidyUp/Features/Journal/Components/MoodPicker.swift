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
    var thumbnail: UIImage? = nil

    var body: some View {
        PACard {
            HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                Text(entry.mood.emoji)
                    .font(.system(size: 26))
                    .frame(width: 48, height: 48)
                    .background(AppTheme.Colors.forMood(entry.mood).opacity(0.15))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.date.formatted(.medium))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.Colors.primaryText)
                        Spacer()
                        Text(entry.mood.label)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppTheme.Colors.forMood(entry.mood))
                    }
                    Text(entry.reflection.isEmpty ? "No reflection written" : entry.reflection)
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .lineLimit(3)

                    if !entry.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack { ForEach(entry.tags, id: \.self) { PATagChip(text: $0) } }
                        }
                    }
                }
            }

            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous))
                    .clipped()
            }
        }
    }
}
