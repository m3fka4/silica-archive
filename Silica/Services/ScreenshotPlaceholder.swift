import Foundation

struct ScreenshotCompressionSuggestion: Identifiable, Hashable {
    var id = UUID()
    var url: URL
    var createdAt: Date
}
