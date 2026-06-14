import XCTest
@testable import Silica

final class SmartAnalyzerTests: XCTestCase {
    func testAnalyzerRecommendsImageOptimizationForImages() async throws {
        let folder = temporaryFolder()
        let imageURL = folder.appendingPathComponent("photo.jpg")
        try Data(repeating: 1, count: 2_000_000).write(to: imageURL)

        let report = try await LocalSmartAnalyzer().analyze(urls: [imageURL])

        XCTAssertEqual(report.recommendedAction, .optimizeImages)
        XCTAssertTrue(report.estimatedSavings > 0)
    }

    private func temporaryFolder() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SilicaTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
