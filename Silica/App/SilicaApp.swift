import SwiftUI

@main
struct SilicaApp: App {
    @NSApplicationDelegateAdaptor(SilicaApplicationDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup("Silica", id: AppRouter.mainWindowID) {
            MainWindowView()
                .environmentObject(appState)
                .frame(minWidth: 1080, minHeight: 720)
                .onAppear {
                    appDelegate.appState = appState
                }
                .task {
                    await appState.prepare()
                }
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open Quick Panel") {
                    appState.requestQuickPanel()
                }
                .keyboardShortcut(" ", modifiers: [.option])

                Button("Smart Compress") {
                    Task { await appState.runSmartAction() }
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
        }

        MenuBarExtra("Silica", systemImage: appState.menuBarSystemImage) {
            MenuBarContentView()
                .environmentObject(appState)
        }
        .menuBarExtraStyle(.menu)

        Window("Silica Quick Panel", id: AppRouter.quickPanelID) {
            QuickPanelView()
                .environmentObject(appState)
                .frame(width: 640, height: 430)
                .background(.ultraThinMaterial)
                .onExitCommand {
                    NSApp.keyWindow?.close()
                }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
