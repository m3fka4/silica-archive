import Foundation

struct SilicaLensReport: Identifiable, Codable, Hashable {
    var id = UUID()
    var originalSize: Int64
    var estimatedSize: Int64
    var estimatedSavings: Int64
    var fileGroups: [FileGroupReport]
    var recommendedAction: RecommendedAction
    var summary: String

    static let mock = SilicaLensReport(
        originalSize: 148_000_000,
        estimatedSize: 61_000_000,
        estimatedSavings: 87_000_000,
        fileGroups: [
            FileGroupReport(kind: .images, fileCount: 42, originalSize: 72_000_000, estimatedSize: 28_000_000, advice: "Optimize and remove metadata"),
            FileGroupReport(kind: .documents, fileCount: 12, originalSize: 34_000_000, estimatedSize: 27_000_000, advice: "Archive as ZIP"),
            FileGroupReport(kind: .archives, fileCount: 3, originalSize: 21_000_000, estimatedSize: 21_000_000, advice: "Already compressed"),
            FileGroupReport(kind: .metadata, fileCount: 42, originalSize: 4_000_000, estimatedSize: 0, advice: "EXIF/GPS can be removed")
        ],
        recommendedAction: .smartCompress,
        summary: "Images and metadata carry most of the saving. Archives should be skipped."
    )
}

enum RecommendedAction: String, Codable, Hashable {
    case smartCompress
    case optimizeImages
    case createZip
    case extractArchive
    case analyzeOnly
    case skip

    var title: String {
        switch self {
        case .smartCompress: "Smart Compress"
        case .optimizeImages: "Optimize Images"
        case .createZip: "Create ZIP"
        case .extractArchive: "Extract Archive"
        case .analyzeOnly: "Analyze with Silica Lens"
        case .skip: "Nothing to compress"
        }
    }

    var symbolName: String {
        switch self {
        case .smartCompress: "sparkles"
        case .optimizeImages: "photo.badge.checkmark"
        case .createZip: "archivebox"
        case .extractArchive: "arrow.down.doc"
        case .analyzeOnly: "camera.macro"
        case .skip: "checkmark.seal"
        }
    }
}
