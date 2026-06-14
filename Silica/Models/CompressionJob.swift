import Foundation

struct CompressionJob: Identifiable, Codable {
    var id = UUID()
    var sourceURLs: [URL]
    var destinationURL: URL?
    var profile: CompressionProfile
    var createdAt = Date()
    var privateMode: Bool
}

enum OperationKind: String, CaseIterable, Codable, Identifiable {
    case smartCompress = "Smart Compress"
    case archiveCompression = "Archive Compression"
    case extraction = "Extract"
    case imageOptimization = "Image Optimization"
    case lensAnalysis = "Silica Lens"

    var id: String { rawValue }
    var title: String { rawValue }

    var symbolName: String {
        switch self {
        case .smartCompress: "sparkles"
        case .archiveCompression: "archivebox"
        case .extraction: "arrow.down.doc"
        case .imageOptimization: "photo"
        case .lensAnalysis: "camera.macro"
        }
    }
}
