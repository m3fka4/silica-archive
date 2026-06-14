import AppKit
import SwiftUI

struct QuickPanelView: View {
    @EnvironmentObject private var appState: AppState
    @State private var query = ""
    @AppStorage("appearance") private var appearance: AppearancePreference = .system
    @AppStorage("accent") private var accent: AccentPreference = .blue

    private let commands: [QuickCommand] = [
        QuickCommand(title: "Compress latest screenshot", symbolName: "camera.viewfinder", operation: .imageOptimization),
        QuickCommand(title: "Smart compress", symbolName: "sparkles", operation: .smartCompress),
        QuickCommand(title: "Extract archive", symbolName: "arrow.down.doc", operation: .extraction),
        QuickCommand(title: "Optimize images", symbolName: "photo.badge.checkmark", operation: .imageOptimization),
        QuickCommand(title: "Create password ZIP", symbolName: "lock.doc", operation: .archiveCompression),
        QuickCommand(title: "Private compress", symbolName: "lock.shield", operation: .smartCompress)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "capsule")
                    .font(.title2)
                Text("Silica")
                    .font(.title2.weight(.semibold))
                Spacer()
                Text("Option Space")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.thinMaterial, in: Capsule())
            }

            TextField("Drop files or type action...", text: $query)
                .textFieldStyle(.plain)
                .font(.title3)
                .padding(14)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .onSubmit {
                    runQuery()
                }

            DropZoneView(title: "Drop files into Quick Panel", subtitle: "Silica will route the action automatically.", minHeight: 124) { urls in
                appState.handleDroppedURLs(urls)
            }

            VStack(spacing: 6) {
                ForEach(filteredCommands) { command in
                    Button {
                        Task {
                            if command.title == "Compress latest screenshot" {
                                await appState.compressLatestScreenshot()
                            } else if command.title == "Smart compress" {
                                await appState.runSmartAction()
                            } else if command.title == "Extract archive" {
                                await appState.extractSelectedArchive()
                            } else if command.title == "Optimize images" {
                                await appState.optimizeSelectedImages(
                                    quality: appState.preferences.defaultImageQuality,
                                    maxWidth: appState.preferences.defaultImageMaxWidth,
                                    maxHeight: appState.preferences.defaultImageMaxHeight,
                                    outputFormat: .jpeg,
                                    removeMetadata: appState.preferences.removeEXIFByDefault,
                                    removeGPS: appState.preferences.removeGPSByDefault
                                )
                            } else {
                                await appState.createArchive(format: .zip, level: .balanced, password: nil, preserveFolders: true, splitSizeMB: nil)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: command.symbolName)
                                .frame(width: 26)
                            Text(command.title)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(24)
        .preferredColorScheme(appearance.colorScheme)
        .tint(accent.color)
        .onExitCommand {
            NSApp.keyWindow?.close()
        }
    }

    private var filteredCommands: [QuickCommand] {
        guard !query.isEmpty else { return commands }
        return commands.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    private func runQuery() {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        Task {
            if normalized.contains("latest screenshot") || normalized.contains("screenshot") {
                await appState.compressLatestScreenshot()
            } else if normalized.contains("clipboard") {
                await appState.compressClipboardFile()
            } else if normalized.contains("latest file") || normalized.contains("downloads") {
                await appState.compressLatestDownloadedFile()
            } else if normalized.contains("extract") {
                await appState.extractSelectedArchive()
            } else if normalized.contains("private") {
                let privateProfile = appState.profiles.first { $0.name.localizedCaseInsensitiveContains("Private") }
                if let privateProfile {
                    await appState.run(profile: privateProfile)
                }
            } else if normalized.contains("settings") {
                appState.selectedSection = .settings
            } else {
                await appState.runSmartAction()
            }
        }
    }
}

struct QuickCommand: Identifiable {
    var id = UUID()
    var title: String
    var symbolName: String
    var operation: OperationKind
}
