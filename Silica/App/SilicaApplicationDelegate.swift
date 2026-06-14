import AppKit
import Carbon

final class SilicaApplicationDelegate: NSObject, NSApplicationDelegate {
    weak var appState: AppState?
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard Bundle.main.bundleIdentifier != nil else {
            return
        }

        installHotKeyEventHandler()
        registerQuickPanelHotKey()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(defaultsChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        unregisterQuickPanelHotKey()
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        let urls = filenames.map { URL(filePath: $0) }
        Task { @MainActor in
            appState?.handleDroppedURLs(urls)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc private func defaultsChanged() {
        registerQuickPanelHotKey()
    }

    private func registerQuickPanelHotKey() {
        unregisterQuickPanelHotKey()

        let defaults = UserDefaults.standard
        let isEnabled = defaults.object(forKey: "quickPanelEnabled") as? Bool ?? true
        let rawValue = defaults.string(forKey: "quickPanelHotKey") ?? HotKeyPreference.optionSpace.rawValue
        let preference = HotKeyPreference(rawValue: rawValue) ?? .optionSpace
        guard isEnabled, preference != .disabled else { return }

        let hotKeyID = EventHotKeyID(signature: fourCharCode("SILC"), id: 1)
        var newHotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(preference.keyCode, preference.carbonModifiers, hotKeyID, GetApplicationEventTarget(), 0, &newHotKeyRef)
        if status == noErr {
            hotKeyRef = newHotKeyRef
        }
    }

    private func unregisterQuickPanelHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }

    private func installHotKeyEventHandler() {
        guard eventHandler == nil else { return }
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, userData in
            guard let userData else { return noErr }
            var hotKeyID = EventHotKeyID()
            GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )

            guard hotKeyID.signature == fourCharCode("SILC"), hotKeyID.id == 1 else {
                return noErr
            }

            let delegate = Unmanaged<SilicaApplicationDelegate>.fromOpaque(userData).takeUnretainedValue()
            Task { @MainActor in
                if let appState = delegate.appState {
                    FloatingPanelService.shared.showQuickPanel(appState: appState)
                } else {
                    NotificationCenter.default.post(name: .silicaOpenQuickPanel, object: nil)
                }
            }
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
    }
}

private func fourCharCode(_ string: String) -> OSType {
    string.utf8.reduce(0) { ($0 << 8) + OSType($1) }
}

private extension HotKeyPreference {
    var keyCode: UInt32 {
        switch self {
        case .optionSpace, .controlSpace, .commandShiftSpace, .disabled:
            UInt32(kVK_Space)
        case .optionS:
            UInt32(kVK_ANSI_S)
        }
    }

    var carbonModifiers: UInt32 {
        switch self {
        case .optionSpace, .optionS:
            UInt32(optionKey)
        case .controlSpace:
            UInt32(controlKey)
        case .commandShiftSpace:
            UInt32(cmdKey | shiftKey)
        case .disabled:
            0
        }
    }
}
