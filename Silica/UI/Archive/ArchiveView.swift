import SwiftUI
import UniformTypeIdentifiers

struct ArchiveView: View {
    @EnvironmentObject private var appState: AppState
    @State private var format: ArchiveFormat = .zip
    @State private var level: CompressionLevel = .balanced
    @State private var password = ""
    @State private var preserveFolders = true
    @State private var splitArchive = false
    @State private var showImporter = false
    @State private var mode: ArchiveMode = .create

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ScreenHeader(title: "Archive", subtitle: "Create clean local archives without turning Silica into a file table.")

                HStack(alignment: .top, spacing: 22) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            DropZoneView(title: "Drop files to archive", subtitle: "Folders and mixed selections are supported.") { urls in
                                appState.handleDroppedURLs(urls)
                                appState.selectedSection = .archive
                                mode = urls.contains { ArchiveFormat.infer(from: $0) != nil || ["rar", "iso", "dmg"].contains($0.pathExtension.lowercased()) } ? .extractPreview : .create
                            }
                            .frame(minHeight: 220)

                            Button {
                                showImporter = true
                            } label: {
                                Label("Choose Files", systemImage: "plus")
                            }
                            .controlSize(.large)

                            SelectedFilesSummary()
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Compression")
                                .font(.headline)

                            Picker("Mode", selection: $mode) {
                                Text("Create").tag(ArchiveMode.create)
                                Text("Extract").tag(ArchiveMode.extractPreview)
                            }
                            .pickerStyle(.segmented)
                            .disabled(!appState.hasSelectedArchive && mode == .create)
                            .onChange(of: mode) { _, newValue in
                                if newValue == .extractPreview && !appState.hasSelectedArchive {
                                    mode = .create
                                    appState.archiveStatusMessage = "Selected items are not archives. Create mode is available."
                                }
                            }

                            if mode == .create {
                                Picker("Format", selection: $format) {
                                    ForEach(ArchiveFormat.allCases) { format in
                                        Text(format.displayName).tag(format)
                                    }
                                }

                                Picker("Level", selection: $level) {
                                    ForEach(CompressionLevel.allCases) { level in
                                        Text(level.displayName).tag(level)
                                    }
                                }

                                SecureField("Password", text: $password)

                                Toggle("Preserve folder structure", isOn: $preserveFolders)
                                Toggle("Split archive when possible", isOn: $splitArchive)
                                Text("\(format.shortName): \(format.availabilityDescription)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(appState.archiveStatusMessage)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }

                            Divider()

                            if mode == .create {
                                SilicaPrimaryButton(title: "Start Compression", symbolName: "archivebox") {
                                    Task {
                                        await appState.createArchive(
                                            format: format,
                                            level: level,
                                            password: password,
                                            preserveFolders: preserveFolders,
                                            splitSizeMB: splitArchive ? 500 : nil
                                        )
                                    }
                                }
                            } else {
                                VStack(spacing: 10) {
                                    Button {
                                        Task { await appState.previewSelectedArchive() }
                                    } label: {
                                        Label("Preview Contents", systemImage: "list.bullet.rectangle")
                                    }
                                    .controlSize(.large)
                                    .disabled(!appState.hasSelectedArchive)

                                    Button {
                                        Task { await appState.testSelectedArchive() }
                                    } label: {
                                        Label("Test Archive", systemImage: "checkmark.shield")
                                    }
                                    .controlSize(.large)
                                    .disabled(!appState.hasSelectedArchive)

                                    SilicaPrimaryButton(title: "Extract to Downloads", symbolName: "arrow.down.doc") {
                                        Task { await appState.extractSelectedArchive() }
                                    }
                                    .disabled(!appState.hasSelectedArchive)
                                }
                            }
                        }
                    }
                    .frame(width: 360)
                }

                if mode == .extractPreview {
                    GlassCard {
                        ArchivePreviewView(items: appState.archivePreviewItems)
                    }
                }
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            if case .success(let urls) = result {
                appState.handleDroppedURLs(urls)
                mode = urls.contains { ArchiveFormat.infer(from: $0) != nil || ["rar", "iso", "dmg"].contains($0.pathExtension.lowercased()) } ? .extractPreview : .create
            }
        }
        .onChange(of: appState.selectedURLs) { _, _ in
            if !appState.hasSelectedArchive && mode == .extractPreview {
                mode = .create
            }
        }
    }
}

enum ArchiveMode: String, CaseIterable, Identifiable {
    case create = "Create"
    case extractPreview = "Extract"

    var id: String { rawValue }
}

struct SelectedFilesSummary: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected")
                .font(.headline)

            if appState.selectedURLs.isEmpty {
                Text("No files selected")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(appState.selectedURLs.prefix(6), id: \.self) { url in
                    HStack {
                        Image(systemName: "doc")
                        Text(url.lastPathComponent)
                            .lineLimit(1)
                        Spacer()
                    }
                    .font(.callout)
                }
            }
        }
    }
}
