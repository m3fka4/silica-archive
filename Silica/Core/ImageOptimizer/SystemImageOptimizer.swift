import Foundation
import ImageIO
import UniformTypeIdentifiers

struct SystemImageOptimizer: ImageOptimizer {
    func optimizeImage(inputURL: URL, outputURL: URL, options: ImageOptimizationOptions) async throws -> ImageOptimizationResult {
        try await Task.detached {
            let originalSize = try inputURL.resourceValues(forKeys: [.fileSizeKey]).fileSize.map(Int64.init) ?? 0
            guard let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil) else {
                throw ImageOptimizerError.couldNotReadImage
            }

            let image = try makeImage(from: source, options: options)
            try FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)

            guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, options.outputFormat.typeIdentifier as CFString, 1, nil) else {
                throw ImageOptimizerError.couldNotWriteImage
            }

            let destinationOptions: [CFString: Any] = [
                kCGImageDestinationLossyCompressionQuality: max(0.1, min(options.quality, 1.0))
            ]

            CGImageDestinationAddImage(destination, image, destinationOptions as CFDictionary)
            guard CGImageDestinationFinalize(destination) else {
                throw ImageOptimizerError.couldNotWriteImage
            }

            let outputSize = try outputURL.resourceValues(forKeys: [.fileSizeKey]).fileSize.map(Int64.init) ?? 0
            let savedBytes = max(originalSize - outputSize, 0)
            let savedPercent = originalSize > 0 ? Double(savedBytes) / Double(originalSize) : 0

            return ImageOptimizationResult(
                originalSize: originalSize,
                outputSize: outputSize,
                savedBytes: savedBytes,
                savedPercent: savedPercent,
                outputURL: outputURL
            )
        }.value
    }

    func batchOptimize(inputURLs: [URL], outputFolder: URL, options: ImageOptimizationOptions) async throws -> [ImageOptimizationResult] {
        try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true)
        var results: [ImageOptimizationResult] = []

        for inputURL in inputURLs {
            let name = inputURL.deletingPathExtension().lastPathComponent
            let preferredURL = outputFolder.appendingPathComponent("\(name)\(options.suffix).\(options.outputFormat.fileExtension)")
            let outputURL = uniqueOutputURL(preferredURL)
            let result = try await optimizeImage(inputURL: inputURL, outputURL: outputURL, options: options)
            results.append(result)
        }

        return results
    }

    private func makeImage(from source: CGImageSource, options: ImageOptimizationOptions) throws -> CGImage {
        let maxDimension = max(options.maxWidth ?? 0, options.maxHeight ?? 0)
        if maxDimension > 0 {
            let thumbnailOptions: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimension
            ]
            guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
                throw ImageOptimizerError.couldNotReadImage
            }
            return image
        }

        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ImageOptimizerError.couldNotReadImage
        }
        return image
    }

    private func uniqueOutputURL(_ url: URL) -> URL {
        var candidate = url
        let base = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        var index = 2

        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = url.deletingLastPathComponent().appendingPathComponent("\(base)-\(index).\(ext)")
            index += 1
        }

        return candidate
    }
}

enum ImageOptimizerError: LocalizedError {
    case couldNotReadImage
    case couldNotWriteImage

    var errorDescription: String? {
        switch self {
        case .couldNotReadImage: "Silica could not read this image."
        case .couldNotWriteImage: "Silica could not write the optimized image."
        }
    }
}
