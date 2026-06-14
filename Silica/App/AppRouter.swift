import Foundation

enum AppRouter {
    static let mainWindowID = "silica-main"
    static let quickPanelID = "silica-quick-panel"
}

enum SidebarSection: String, CaseIterable, Identifiable {
    case smart = "Smart"
    case archive = "Archive"
    case images = "Images"
    case lens = "Lens"
    case history = "History"
    case profiles = "Profiles"
    case settings = "Settings"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .smart: "sparkles"
        case .archive: "archivebox"
        case .images: "photo.on.rectangle.angled"
        case .lens: "camera.macro"
        case .history: "clock.arrow.circlepath"
        case .profiles: "slider.horizontal.3"
        case .settings: "gearshape"
        }
    }
}
