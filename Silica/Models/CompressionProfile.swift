import Foundation

struct CompressionProfile: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var operation: OperationKind
    var archiveFormat: ArchiveFormat
    var compressionLevel: CompressionLevel
    var imageQuality: Double
    var maxWidth: Int?
    var maxHeight: Int?
    var removeEXIF: Bool
    var removeGPS: Bool
    var destinationMode: DestinationMode
    var savesHistory: Bool
    var access: FeatureAccess

    static let defaults: [CompressionProfile] = [
        CompressionProfile(
            name: "Telegram",
            operation: .imageOptimization,
            archiveFormat: .zip,
            compressionLevel: .balanced,
            imageQuality: 0.82,
            maxWidth: 1920,
            maxHeight: 1920,
            removeEXIF: true,
            removeGPS: true,
            destinationMode: .silicaOptimizedFolder,
            savesHistory: true,
            access: .free
        ),
        CompressionProfile(
            name: "Website",
            operation: .imageOptimization,
            archiveFormat: .zip,
            compressionLevel: .balanced,
            imageQuality: 0.78,
            maxWidth: 2400,
            maxHeight: 2400,
            removeEXIF: true,
            removeGPS: true,
            destinationMode: .silicaOptimizedFolder,
            savesHistory: true,
            access: .free
        ),
        CompressionProfile(
            name: "Private Mode",
            operation: .smartCompress,
            archiveFormat: .zip,
            compressionLevel: .balanced,
            imageQuality: 0.84,
            maxWidth: nil,
            maxHeight: nil,
            removeEXIF: true,
            removeGPS: true,
            destinationMode: .askEveryTime,
            savesHistory: false,
            access: .pro
        ),
        CompressionProfile(
            name: "Fast ZIP",
            operation: .archiveCompression,
            archiveFormat: .zip,
            compressionLevel: .fast,
            imageQuality: 0.9,
            maxWidth: nil,
            maxHeight: nil,
            removeEXIF: false,
            removeGPS: false,
            destinationMode: .nextToOriginal,
            savesHistory: true,
            access: .free
        ),
        CompressionProfile(
            name: "Maximum Compression",
            operation: .archiveCompression,
            archiveFormat: .sevenZ,
            compressionLevel: .maximum,
            imageQuality: 0.8,
            maxWidth: nil,
            maxHeight: nil,
            removeEXIF: false,
            removeGPS: false,
            destinationMode: .nextToOriginal,
            savesHistory: true,
            access: .pro
        ),
        CompressionProfile(
            name: "Email",
            operation: .smartCompress,
            archiveFormat: .zip,
            compressionLevel: .balanced,
            imageQuality: 0.76,
            maxWidth: 1600,
            maxHeight: 1600,
            removeEXIF: true,
            removeGPS: true,
            destinationMode: .silicaOptimizedFolder,
            savesHistory: true,
            access: .free
        )
    ]
}

enum DestinationMode: String, CaseIterable, Codable, Identifiable {
    case nextToOriginal = "Next to original"
    case downloads = "Downloads"
    case askEveryTime = "Always ask"
    case customFolder = "Custom folder"
    case silicaOptimizedFolder = "Silica Optimized"

    var id: String { rawValue }
}
