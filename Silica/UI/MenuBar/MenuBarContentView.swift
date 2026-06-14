import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            Text("Silica")
                .font(.headline)

            Button {
                openWindow(id: AppRouter.mainWindowID)
            } label: {
                Label("Open Main Window", systemImage: "macwindow")
            }

            Button {
                appState.requestQuickPanel()
            } label: {
                Label("Open Floating Quick Panel", systemImage: "command")
            }

            Divider()
            Text("Quick Actions")

            Button {
                Task { await appState.compressLatestScreenshot() }
            } label: {
                Label("Compress Latest Screenshot", systemImage: "camera.viewfinder")
            }

            Button {
                Task { await appState.compressClipboardFile() }
            } label: {
                Label("Compress Clipboard File", systemImage: "doc.on.clipboard")
            }

            Button {
                Task { await appState.compressLatestDownloadedFile() }
            } label: {
                Label("Compress Latest File", systemImage: "clock.badge.checkmark")
            }

            Button {
                Task { await appState.createArchive(format: .zip, level: .fast, password: nil, preserveFolders: true, splitSizeMB: nil) }
            } label: {
                Label("Quick ZIP Selected Files", systemImage: "archivebox")
            }
            .disabled(appState.selectedURLs.isEmpty)

            Button {
                Task { await appState.extractSelectedArchive() }
            } label: {
                Label("Extract Selected Archive", systemImage: "arrow.down.doc")
            }
            .disabled(!appState.hasSelectedArchive)

            Divider()

            Menu("Recent Archives") {
                ForEach(appState.historyService.items.prefix(5)) { item in
                    Button(item.outputURL.lastPathComponent) {
                        FinderService().reveal(item.outputURL)
                    }
                }
            }

            Divider()

            Text(statusText)
            Button("Settings") {
                appState.selectedSection = .settings
                openWindow(id: AppRouter.mainWindowID)
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    private var statusText: String {
        switch appState.operationStatus {
        case .idle: "Status: idle"
        case .compressing: "Status: compressing"
        case .done: "Status: done"
        case .error: "Status: error"
        }
    }
}
