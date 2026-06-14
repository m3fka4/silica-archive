import Foundation

enum ArchiveFormat: String, CaseIterable, Codable, Identifiable {
    case zip = "ZIP"
    case sevenZ = "7Z"
    case tar = "TAR"
    case tarGzip = "TAR.GZ"
    case gzip = "GZIP"
    case xz = "XZ"
    case bzip2 = "BZIP2"
    case zstd = "ZSTD"

    var id: String { rawValue }

    var fileExtension: String {
        switch self {
        case .zip: "zip"
        case .sevenZ: "7z"
        case .tar: "tar"
        case .tarGzip: "tar.gz"
        case .gzip: "gz"
        case .xz: "xz"
        case .bzip2: "bz2"
        case .zstd: "zst"
        }
    }

    var displayName: String {
        switch self {
        case .zip: "ZIP (.zip)"
        case .sevenZ: "7Z (.7z, requires 7zz)"
        case .tar: "TAR (.tar)"
        case .tarGzip: "TAR.GZ (.tar.gz)"
        case .gzip: "GZIP (.gz)"
        case .xz: "XZ (.xz)"
        case .bzip2: "BZIP2 (.bz2)"
        case .zstd: "ZSTD (.zst, planned)"
        }
    }

    var shortName: String {
        switch self {
        case .zip: "ZIP"
        case .sevenZ: "7Z"
        case .tar: "TAR"
        case .tarGzip: "TAR.GZ"
        case .gzip: "GZIP"
        case .xz: "XZ"
        case .bzip2: "BZIP2"
        case .zstd: "ZSTD"
        }
    }

    var availabilityDescription: String {
        switch self {
        case .zip: "Built in"
        case .tar, .tarGzip, .gzip, .xz, .bzip2: "Built in via macOS tar"
        case .sevenZ: "Requires 7zz or 7z"
        case .zstd: "Planned"
        }
    }

    static func infer(from url: URL) -> ArchiveFormat? {
        let name = url.lastPathComponent.lowercased()
        let ext = url.pathExtension.lowercased()

        if name.hasSuffix(".tar.gz") || ext == "tgz" { return .tarGzip }
        if ["zip", "apk", "ipa", "jar"].contains(ext) { return .zip }
        if ext == "7z" { return .sevenZ }
        if ext == "tar" { return .tar }
        if ext == "gz" { return .gzip }
        if ext == "xz" { return .xz }
        if ext == "bz2" { return .bzip2 }
        if ext == "zst" || ext == "zstd" { return .zstd }
        return nil
    }

    var isSystemReadable: Bool {
        switch self {
        case .zip, .tar, .tarGzip, .gzip, .xz, .bzip2:
            true
        case .sevenZ, .zstd:
            false
        }
    }
}

enum CompressionLevel: String, CaseIterable, Codable, Identifiable {
    case fast = "Fast"
    case balanced = "Balanced"
    case maximum = "Maximum"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fast: "Fast - quick result"
        case .balanced: "Balanced - recommended"
        case .maximum: "Maximum - slower, smaller"
        }
    }
}

enum FeatureAccess: String, Codable {
    case free
    case pro
}
