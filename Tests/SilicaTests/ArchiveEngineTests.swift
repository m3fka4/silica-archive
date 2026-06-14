import XCTest
@testable import Silica

final class ArchiveEngineTests: XCTestCase {
    func testZipCreateListAndExtract() async throws {
        let root = temporaryFolder()
        let input = root.appendingPathComponent("input.txt")
        try "Silica".data(using: .utf8)!.write(to: input)

        let archive = root.appendingPathComponent("test.zip")
        let output = root.appendingPathComponent("out", isDirectory: true)
        let engine = SystemArchiveEngine()

        try await engine.createArchive(
            files: [input],
            destinationURL: archive,
            format: .zip,
            options: CompressionOptions(level: .fast, password: nil, preserveFolderStructure: true, splitSizeMB: nil)
        )

        let items = try await engine.listContents(archiveURL: archive)
        XCTAssertTrue(items.contains { $0.path.contains("input.txt") })

        let result = try await engine.testArchive(archiveURL: archive)
        XCTAssertTrue(result.isValid)

        try await engine.extract(archiveURL: archive, destinationURL: output)
        XCTAssertTrue(FileManager.default.fileExists(atPath: output.appendingPathComponent("input.txt").path))
    }

    private func temporaryFolder() -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SilicaTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
