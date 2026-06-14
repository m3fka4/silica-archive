import Foundation
import ImageIO

protocol ImageOptimizer {
    func optimizeImage(inputURL: URL, outputURL: URL, options: ImageOptimizationOptions) async throws -> ImageOptimizationResult
    func batchOptimize(inputURLs: [URL], outputFolder: URL, options: ImageOptimizationOptions) async throws -> [ImageOptimizationResult]
}

struct ImageOptimizationOptions: Codable, Hashable {
    var quality: Double
    var maxWidth: Int?
    var maxHeight: Int?
    var outputFormat: ImageOutputFormat
    var removeMetadata: Bool
    var removeGPS: Bool
    var preserveOriginal: Bool
    var suffix: String
    var destinationFolder: URL?
}

enum ImageOutputFormat: String, CaseIterable, Codable, Identifiable {
    case jpeg = "JPEG"
    case png = "PNG"
    case heic = "HEIC"
    case webp = "WEBP"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .jpeg: "jpg"
        case .png: "png"
        case .heic: "heic"
        case .webp: "webp"
        }
    }

    var displayName: String {
        switch self {
        case .jpeg: "JPEG (.jpg) - photos, sharing"
        case .png: "PNG (.png) - screenshots, lossless"
        case .heic: "HEIC (.heic) - Apple devices"
        case .webp: "WEBP (.webp) - web"
        }
    }

    var typeIdentifier: String {
        switch self {
        case .jpeg: "public.jpeg"
        case .png: "public.png"
        case .heic: "public.heic"
        case .webp: "org.webmproject.webp"
        }
    }

    var isAvailable: Bool {
        let identifiers = CGImageDestinationCopyTypeIdentifiers() as NSArray
        return identifiers.compactMap { $0 as? String }.contains(typeIdentifier)
    }
}
