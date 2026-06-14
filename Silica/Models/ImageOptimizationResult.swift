import Foundation

struct ImageOptimizationResult: Identifiable, Codable, Hashable {
    var id = UUID()
    let originalSize: Int64
    let outputSize: Int64
    let savedBytes: Int64
    let savedPercent: Double
    let outputURL: URL
}
