import Foundation

struct SystemArchiveEngine: ArchiveEngine {
    var availability: ArchiveBackendAvailability {
        ArchiveBackendAvailability(
            zip: executableExists("/usr/bin/zip") && executableExists("/usr/bin/unzip"),
            tar: executableExists("/usr/bin/tar"),
            sevenZ: executableExists("/usr/local/bin/7zz") || executableExists("/opt/homebrew/bin/7zz") || executableExists("/usr/local/bin/7z") || executableExists("/opt/homebrew/bin/7z"),
            rar: executableExists("/usr/local/bin/unrar") || executableExists("/opt/homebrew/bin/unrar") || executableExists("/usr/local/bin/unar") || executableExists("/opt/homebrew/bin/unar"),
            diskImages: executableExists("/usr/bin/hdiutil")
        )
    }

    func extract(archiveURL: URL, destinationURL: URL) async throws {
        guard let format = ArchiveFormat.infer(from: archiveURL) else {
            throw ArchiveEngineError.unsupportedFormat
        }

        try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true)

        switch format {
        case .zip:
            try await run("/usr/bin/unzip", arguments: ["-o", archiveURL.path, "-d", destinationURL.path])
        case .tar:
            try await run("/usr/bin/tar", arguments: ["-xf", archiveURL.path, "-C", destinationURL.path])
        case .tarGzip, .gzip:
            try await run("/usr/bin/tar", arguments: ["-xzf", archiveURL.path, "-C", destinationURL.path])
        case .bzip2:
            try await run("/usr/bin/tar", arguments: ["-xjf", archiveURL.path, "-C", destinationURL.path])
        case .xz:
            try await run("/usr/bin/tar", arguments: ["-xJf", archiveURL.path, "-C", destinationURL.path])
        case .sevenZ:
            _ = try await runSevenZip(arguments: ["x", "-y", "-o\(destinationURL.path)", archiveURL.path])
        case .zstd:
            throw ArchiveEngineError.backendUnavailable("ZSTD")
        }
    }

    func createArchive(files: [URL], destinationURL: URL, format: ArchiveFormat, options: CompressionOptions) async throws {
        guard !files.isEmpty else {
            throw ArchiveEngineError.fileNotFound
        }

        let stagingURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("SilicaArchive-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: stagingURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: stagingURL) }

        for file in files {
            let stagedURL = uniqueURL(for: file.lastPathComponent, in: stagingURL)
            try FileManager.default.copyItem(at: file, to: stagedURL)
        }

        switch format {
        case .zip:
            if let password = options.password, !password.isEmpty {
                try await run("/usr/bin/zip", arguments: ["-r", "-P", password, destinationURL.path, "."], currentDirectoryURL: stagingURL)
            } else {
                try await run("/usr/bin/ditto", arguments: ["-c", "-k", "--sequesterRsrc", stagingURL.path, destinationURL.path])
            }
        case .tar:
            try await run("/usr/bin/tar", arguments: ["-cf", destinationURL.path, "-C", stagingURL.path, "."])
        case .tarGzip:
            try await run("/usr/bin/tar", arguments: ["-czf", destinationURL.path, "-C", stagingURL.path, "."])
        case .bzip2:
            try await run("/usr/bin/tar", arguments: ["-cjf", destinationURL.path, "-C", stagingURL.path, "."])
        case .xz:
            try await run("/usr/bin/tar", arguments: ["-cJf", destinationURL.path, "-C", stagingURL.path, "."])
        case .gzip:
            try await run("/usr/bin/tar", arguments: ["-czf", destinationURL.path, "-C", stagingURL.path, "."])
        case .sevenZ:
            var arguments = ["a", "-t7z", destinationURL.path, "."]
            if let password = options.password, !password.isEmpty {
                arguments.insert("-p\(password)", at: 2)
                arguments.insert("-mhe=on", at: 3)
            }
            _ = try await runSevenZip(arguments: arguments, currentDirectoryURL: stagingURL)
        case .zstd:
            throw ArchiveEngineError.backendUnavailable("ZSTD")
        }
    }

    func listContents(archiveURL: URL) async throws -> [ArchiveItem] {
        guard let format = ArchiveFormat.infer(from: archiveURL) else {
            throw ArchiveEngineError.unsupportedFormat
        }

        let output: String
        switch format {
        case .zip:
            output = try await run("/usr/bin/zipinfo", arguments: ["-1", archiveURL.path])
        case .tar, .tarGzip, .gzip, .bzip2, .xz:
            output = try await run("/usr/bin/tar", arguments: ["-tf", archiveURL.path])
        case .sevenZ:
            output = try await runSevenZip(arguments: ["l", "-ba", archiveURL.path])
        case .zstd:
            throw ArchiveEngineError.backendUnavailable("ZSTD")
        }

        return output
            .split(separator: "\n")
            .map { line in
                let path = archivePath(from: String(line), format: format)
                return ArchiveItem(path: path, size: 0, isDirectory: path.hasSuffix("/"))
            }
    }

    func testArchive(archiveURL: URL) async throws -> ArchiveTestResult {
        guard let format = ArchiveFormat.infer(from: archiveURL) else {
            throw ArchiveEngineError.unsupportedFormat
        }

        switch format {
        case .zip:
            _ = try await run("/usr/bin/unzip", arguments: ["-t", archiveURL.path])
        case .tar, .tarGzip, .gzip, .bzip2, .xz:
            _ = try await run("/usr/bin/tar", arguments: ["-tf", archiveURL.path])
        case .sevenZ:
            _ = try await runSevenZip(arguments: ["t", archiveURL.path])
        case .zstd:
            throw ArchiveEngineError.backendUnavailable("ZSTD")
        }

        return ArchiveTestResult(isValid: true, message: "Archive looks valid.")
    }

    func mountDiskImage(_ archiveURL: URL) async throws -> String {
        guard availability.diskImages else { throw ArchiveEngineError.backendUnavailable("hdiutil") }
        return try await run("/usr/bin/hdiutil", arguments: ["attach", archiveURL.path, "-nobrowse"])
    }

    @discardableResult
    private func run(_ launchPath: String, arguments: [String], currentDirectoryURL: URL? = nil) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(filePath: launchPath)
            process.arguments = arguments
            process.currentDirectoryURL = currentDirectoryURL

            let pipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = pipe
            process.standardError = errorPipe

            process.terminationHandler = { process in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

                if process.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    continuation.resume(throwing: ArchiveEngineError.backendFailed(errorOutput.isEmpty ? output : errorOutput))
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func uniqueURL(for fileName: String, in folder: URL) -> URL {
        let base = URL(filePath: fileName).deletingPathExtension().lastPathComponent
        let ext = URL(filePath: fileName).pathExtension
        var candidate = folder.appendingPathComponent(fileName)
        var index = 2

        while FileManager.default.fileExists(atPath: candidate.path) {
            let name = ext.isEmpty ? "\(base)-\(index)" : "\(base)-\(index).\(ext)"
            candidate = folder.appendingPathComponent(name)
            index += 1
        }

        return candidate
    }

    private func runSevenZip(arguments: [String], currentDirectoryURL: URL? = nil) async throws -> String {
        let candidates = [
            "/opt/homebrew/bin/7zz",
            "/usr/local/bin/7zz",
            "/opt/homebrew/bin/7z",
            "/usr/local/bin/7z"
        ]

        guard let executable = candidates.first(where: executableExists) else {
            throw ArchiveEngineError.backendUnavailable("7Z")
        }

        return try await run(executable, arguments: arguments, currentDirectoryURL: currentDirectoryURL)
    }

    private func executableExists(_ path: String) -> Bool {
        FileManager.default.isExecutableFile(atPath: path)
    }
}

private func archivePath(from line: String, format: ArchiveFormat) -> String {
    guard format == .sevenZ else { return line }
    let parts = line.split(separator: " ", omittingEmptySubsequences: true)
    guard parts.count >= 6 else { return line }
    return parts.dropFirst(5).joined(separator: " ")
}
