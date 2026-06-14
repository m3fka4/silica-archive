import AppKit
import SwiftUI

@MainActor
final class FloatingPanelService {
    static let shared = FloatingPanelService()
    private var quickPanel: NSPanel?

    func showQuickPanel(appState: AppState) {
        if quickPanel == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 660, height: 460),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            panel.title = "Silica"
            panel.titleVisibility = .hidden
            panel.titlebarAppearsTransparent = true
            panel.isMovableByWindowBackground = true
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.contentView = NSHostingView(
                rootView: QuickPanelView()
                    .environmentObject(appState)
                    .frame(width: 660, height: 460)
                    .background(.ultraThinMaterial)
            )
            quickPanel = panel
        }

        positionQuickPanel()
        NSApp.activate(ignoringOtherApps: true)
        quickPanel?.makeKeyAndOrderFront(nil)
    }

    private func positionQuickPanel() {
        guard let panel = quickPanel, let screen = NSScreen.main else {
            quickPanel?.center()
            return
        }

        let experimentalNotchMode = UserDefaults.standard.bool(forKey: "experimentalNotchMode")
        guard experimentalNotchMode else {
            panel.center()
            return
        }

        let visible = screen.visibleFrame
        let x = visible.midX - panel.frame.width / 2
        let topPadding: CGFloat = 18
        let y = visible.maxY - panel.frame.height - topPadding
        panel.setFrameOrigin(NSPoint(x: max(visible.minX + 12, x), y: max(visible.minY + 12, y)))
    }
}
