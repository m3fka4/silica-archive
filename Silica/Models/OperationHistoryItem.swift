import Foundation

struct OperationHistoryItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var operation: OperationKind
    var sourceSize: Int64
    var resultSize: Int64
    var outputURL: URL
    var usedProfileName: String

    var savedBytes: Int64 {
        max(sourceSize - resultSize, 0)
    }

    var savedPercent: Double {
        guard sourceSize > 0 else { return 0 }
        return Double(savedBytes) / Double(sourceSize)
    }

    static let mocks: [OperationHistoryItem] = [
        OperationHistoryItem(
            date: .now.addingTimeInterval(-3_600),
            operation: .imageOptimization,
            sourceSize: 72_000_000,
            resultSize: 28_000_000,
            outputURL: URL(filePath: "\(NSHomeDirectory())/Downloads/Silica Optimized/photos"),
            usedProfileName: "Telegram"
        ),
        OperationHistoryItem(
            date: .now.addingTimeInterval(-86_400),
            operation: .archiveCompression,
            sourceSize: 148_000_000,
            resultSize: 61_000_000,
            outputURL: URL(filePath: "\(NSHomeDirectory())/Downloads/project.zip"),
            usedProfileName: "Fast ZIP"
        )
    ]
}
