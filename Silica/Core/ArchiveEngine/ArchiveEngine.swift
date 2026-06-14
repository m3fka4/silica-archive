import Foundation

protocol ArchiveEngine {
    func extract(archiveURL: URL, destinationURL: URL) async throws
    func createArchive(files: [URL], destinationURL: URL, format: ArchiveFormat, options: CompressionOptions) async throws
    func listContents(archiveURL: URL) async throws -> [ArchiveItem]
    func testArchive(archiveURL: URL) async throws -> ArchiveTestResult
}

struct CompressionOptions: Codable, Hashable {
    var level: CompressionLevel
    var password: String?
    var preserveFolderStructure: Bool
    var splitSizeMB: Int?
}

struct ArchiveItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var path: String
    var size: Int64
    var isDirectory: Bool
}

struct ArchiveTestResult: Codable, Hashable {
    var isValid: Bool
    var message: String
}

struct ArchiveBackendAvailability: Codable, Hashable {
    var zip: Bool
    var tar: Bool
    var sevenZ: Bool
    var rar: Bool
    var diskImages: Bool
}

enum ArchiveEngineError: LocalizedError {
    case archiveDamaged
    case passwordRequired
    case wrongPassword
    case unsupportedFormat
    case backendUnavailable(String)
    case cannotWriteDestination
    case cancelled
    case fileNotFound
    case notEnoughSpace
    case backendFailed(String)

    var errorDescription: String? {
        switch self {
        case .archiveDamaged: "Couldn’t extract this archive. The archive may be damaged or password protected."
        case .passwordRequired: "Password required. Enter the archive password to continue."
        case .wrongPassword: "Wrong password."
        case .unsupportedFormat: "This archive format is not supported yet."
        case .backendUnavailable(let name): "\(name) backend is not installed or not available on this Mac."
        case .cannotWriteDestination: "Silica could not write to the selected destination."
        case .cancelled: "The operation was cancelled."
        case .fileNotFound: "File not found."
        case .notEnoughSpace: "Not enough space. Choose another destination or free up disk space."
        case .backendFailed(let message): message
        }
    }
}
