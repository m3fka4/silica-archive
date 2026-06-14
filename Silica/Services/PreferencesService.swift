import Foundation
import SwiftUI

@MainActor
final class PreferencesService: ObservableObject {
    @AppStorage("appearance") var appearance: AppearancePreference = .system
    @AppStorage("accent") var accent: AccentPreference = .blue
    @AppStorage("interfaceSize") var interfaceSize: InterfaceSizePreference = .comfortable
    @AppStorage("saveHistory") var saveHistory = true
    @AppStorage("privateModeByDefault") var privateModeByDefault = false
    @AppStorage("removeEXIFByDefault") var removeEXIFByDefault = true
    @AppStorage("removeGPSByDefault") var removeGPSByDefault = true
    @AppStorage("showNotifications") var showNotifications = true
    @AppStorage("showMenuBarIcon") var showMenuBarIcon = true
    @AppStorage("offerScreenshotCompression") var offerScreenshotCompression = true
    @AppStorage("finderActionsEnabled") var finderActionsEnabled = true
    @AppStorage("destinationMode") var destinationMode: DestinationMode = .nextToOriginal
    @AppStorage("defaultArchiveFormat") var defaultArchiveFormat: ArchiveFormat = .zip
    @AppStorage("defaultCompressionLevel") var defaultCompressionLevel: CompressionLevel = .balanced
    @AppStorage("defaultImageQuality") var defaultImageQuality = 0.82
    @AppStorage("defaultImageMaxWidth") var defaultImageMaxWidth = 1920
    @AppStorage("defaultImageMaxHeight") var defaultImageMaxHeight = 1920
    @AppStorage("quickPanelEnabled") var quickPanelEnabled = true
    @AppStorage("quickPanelHotKey") var quickPanelHotKey: HotKeyPreference = .optionSpace
    @AppStorage("experimentalNotchMode") var experimentalNotchMode = false
    @AppStorage("playCompletionSound") var playCompletionSound = false
    @AppStorage("warnBeforeSensitiveFiles") var warnBeforeSensitiveFiles = true
    @AppStorage("appLanguage") var appLanguage: AppLanguage = .system
    @AppStorage("onboardingComplete") var onboardingComplete = false
    @AppStorage("showCompletionHUD") var showCompletionHUD = true
}

enum HotKeyPreference: String, CaseIterable, Identifiable {
    case optionSpace = "Option + Space"
    case controlSpace = "Control + Space"
    case commandShiftSpace = "Command + Shift + Space"
    case optionS = "Option + S"
    case disabled = "Disabled"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "System"
    case english = "English"
    case russian = "Русский"

    var id: String { rawValue }

    var usesRussian: Bool {
        switch self {
        case .russian:
            true
        case .english:
            false
        case .system:
            Locale.current.language.languageCode?.identifier == "ru"
        }
    }
}

enum AppearancePreference: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum AccentPreference: String, CaseIterable, Identifiable {
    case blue = "Blue"
    case graphite = "Graphite"
    case purple = "Purple"
    case green = "Green"
    case orange = "Orange"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: .blue
        case .graphite: .gray
        case .purple: .purple
        case .green: .green
        case .orange: .orange
        }
    }
}

enum InterfaceSizePreference: String, CaseIterable, Identifiable {
    case compact = "Compact"
    case comfortable = "Comfortable"
    case large = "Large"

    var id: String { rawValue }

    var controlSize: ControlSize {
        switch self {
        case .compact: .small
        case .comfortable: .regular
        case .large: .large
        }
    }
}
