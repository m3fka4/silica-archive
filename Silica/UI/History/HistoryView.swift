import AppKit
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appState: AppState
    private let finder = FinderService()
    @State private var filter: OperationKind?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ScreenHeader(title: "History", subtitle: "Recent local operations. Private Mode can skip this entirely.")

                Picker("Filter", selection: $filter) {
                    Text("All").tag(OperationKind?.none)
                    ForEach(OperationKind.allCases) { kind in
                        Text(kind.title).tag(OperationKind?.some(kind))
                    }
                }
                .pickerStyle(.segmented)

                if filteredItems.isEmpty {
                    GlassCard {
                        EmptyStateText(title: "No history", subtitle: "Completed operations will appear here when history is enabled.")
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredItems) { item in
                            HistoryRow(item: item) {
                                finder.reveal(item.outputURL)
                            } repeatAction: {
                                Task { await appState.repeatOperation(item) }
                            } deleteAction: {
                                appState.historyService.delete(item)
                            }
                        }
                    }
                }
            }
        }
    }

    private var filteredItems: [OperationHistoryItem] {
        guard let filter else { return appState.historyService.items }
        return appState.historyService.items.filter { $0.operation == filter }
    }
}

struct HistoryRow: View {
    let item: OperationHistoryItem
    let revealAction: () -> Void
    let repeatAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        GlassCard(padding: 16) {
            HStack(spacing: 16) {
                Image(systemName: item.operation.symbolName)
                    .font(.title2)
                    .frame(width: 46, height: 46)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.operation.title)
                        .font(.headline)
                    Text(item.outputURL.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text(DateFormatter.silicaHistory.string(from: item.date))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Saved \(ByteCountFormatter.silica.string(fromByteCount: item.savedBytes))")
                        .font(.headline)
                    Text("\(Int(item.savedPercent * 100))% smaller")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("Show in Finder", action: revealAction)
                Button("Repeat", action: repeatAction)
                Button(role: .destructive, action: deleteAction) {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
