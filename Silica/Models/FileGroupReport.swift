import Foundation

struct FileGroupReport: Identifiable, Codable, Hashable {
    var id = UUID()
    var kind: FileGroupKind
    var fileCount: Int
    var originalSize: Int64
    var estimatedSize: Int64
    var advice: String

    var savings: Int64 {
        max(originalSize - estimatedSize, 0)
    }

    var savingsPercent: Double {
        guard originalSize > 0 else { return 0 }
        return Double(savings) / Double(originalSize)
    }
}

enum FileGroupKind: String, CaseIterable, Codable, Hashable, Identifiable {
    case images = "Images"
    case documents = "Documents"
    case archives = "Archives"
    case videos = "Videos"
    case folders = "Folders"
    case audio = "Audio"
    case code = "Code"
    case metadata = "Metadata"
    case unknown = "Unknown"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .images: "photo"
        case .documents: "doc.text"
        case .archives: "archivebox"
        case .videos: "video"
        case .folders: "folder"
        case .audio: "waveform"
        case .code: "curlybraces"
        case .metadata: "location.slash"
        case .unknown: "questionmark.folder"
        }
    }
}
