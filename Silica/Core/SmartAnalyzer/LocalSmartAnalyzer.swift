import Foundation
import ImageIO
import UniformTypeIdentifiers

struct LocalSmartAnalyzer {
    func analyze(urls: [URL]) async throws -> SilicaLensReport {
        try await Task.detached {
            var buckets: [FileGroupKind: (count: Int, size: Int64)] = [:]

            for url in urls {
                let entries = try expand(url: url)
                for entry in entries {
                    let kind = classify(entry)
                    let size = fileSize(entry)
                    let current = buckets[kind] ?? (0, 0)
                    buckets[kind] = (current.count + 1, current.size + size)

                    if kind == .images, imageHasRemovableMetadata(entry) {
                        let metadata = buckets[.metadata] ?? (0, 0)
                        buckets[.metadata] = (metadata.count + 1, metadata.size + min(max(size / 50, 16_384), 4_000_000))
                    }
                }
            }

            let groups = buckets
                .map { kind, value in
                    makeReport(kind: kind, count: value.count, size: value.size)
                }
                .sorted { $0.originalSize > $1.originalSize }

            let original = groups.reduce(Int64(0)) { $0 + $1.originalSize }
            let estimated = groups.reduce(Int64(0)) { $0 + $1.estimatedSize }
            let savings = max(original - estimated, 0)
            let action = recommend(groups: groups)
            let summary = makeSummary(groups: groups, savings: savings)

            return SilicaLensReport(
                originalSize: original,
                estimatedSize: estimated,
                estimatedSavings: savings,
                fileGroups: groups,
                recommendedAction: action,
                summary: summary
            )
        }.value
    }
}

private func expand(url: URL) throws -> [URL] {
    let values = try url.resourceValues(forKeys: [.isDirectoryKey])
    guard values.isDirectory == true else { return [url] }

    let children = FileManager.default.enumerator(
        at: url,
        includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey, .contentTypeKey],
        options: [.skipsHiddenFiles]
    )

    return children?.compactMap { $0 as? URL } ?? []
}

private func fileSize(_ url: URL) -> Int64 {
    let values = try? url.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
    guard values?.isDirectory != true else { return 0 }
    return values?.fileSize.map(Int64.init) ?? 0
}

private func classify(_ url: URL) -> FileGroupKind {
    let ext = url.pathExtension.lowercased()

    if ["png", "jpg", "jpeg", "heic", "webp", "tiff", "gif"].contains(ext) { return .images }
    if ["zip", "rar", "7z", "tar", "gz", "tgz", "bz2", "xz", "apk", "ipa", "jar"].contains(ext) { return .archives }
    if ["mov", "mp4", "m4v", "avi", "mkv"].contains(ext) { return .videos }
    if ["mp3", "m4a", "wav", "aac", "flac"].contains(ext) { return .audio }
    if ["pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "rtf", "txt"].contains(ext) { return .documents }
    if ["swift", "js", "ts", "json", "html", "css", "md", "xml", "yml", "yaml"].contains(ext) { return .code }
    return .unknown
}

private func imageHasRemovableMetadata(_ url: URL) -> Bool {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
        return false
    }

    let metadataKeys: [CFString] = [
        kCGImagePropertyExifDictionary,
        kCGImagePropertyGPSDictionary,
        kCGImagePropertyTIFFDictionary,
        kCGImagePropertyIPTCDictionary
    ]

    return metadataKeys.contains { key in
        guard let value = properties[key] as? [AnyHashable: Any] else { return false }
        return !value.isEmpty
    }
}

private func makeReport(kind: FileGroupKind, count: Int, size: Int64) -> FileGroupReport {
    let ratio = estimatedRatio(kind: kind, size: size, count: count)
    let estimated = Int64(Double(size) * ratio)

    let advice: String = switch kind {
    case .images: "Optimize images and remove EXIF/GPS metadata"
    case .documents: "Archive as ZIP or use Maximum Compression for storage"
    case .archives: "Already compressed; extract, preview or skip"
    case .videos: "Usually not worth recompressing"
    case .folders: "Smart archive with folder structure"
    case .audio: "Skip unless you need a single archive"
    case .code: "ZIP compresses text-heavy projects well"
    case .metadata: "Metadata can be removed privately"
    case .unknown: "Use balanced ZIP and inspect result"
    }

    return FileGroupReport(kind: kind, fileCount: count, originalSize: size, estimatedSize: estimated, advice: advice)
}

private func estimatedRatio(kind: FileGroupKind, size: Int64, count: Int) -> Double {
    let mb = Double(size) / 1_000_000
    let batchBonus = min(Double(count) / 200.0, 0.08)

    switch kind {
    case .images:
        let largeImageBonus = min(mb / 500.0, 0.18)
        return max(0.32, 0.62 - largeImageBonus - batchBonus)
    case .documents:
        return mb > 100 ? 0.72 : 0.80
    case .archives:
        return 0.99
    case .videos:
        return 0.98
    case .folders:
        return 0.78
    case .audio:
        return 0.96
    case .code:
        return 0.34
    case .metadata:
        return 0.0
    case .unknown:
        return 0.88
    }
}

private func recommend(groups: [FileGroupReport]) -> RecommendedAction {
    if groups.count == 1, groups.first?.kind == .archives {
        return .extractArchive
    }

    let imageSavings = groups.filter { $0.kind == .images }.reduce(Int64(0)) { $0 + $1.savings }
    let totalSavings = groups.reduce(Int64(0)) { $0 + $1.savings }

    if imageSavings > 0, imageSavings >= Int64(Double(totalSavings) * 0.55) {
        return .optimizeImages
    }

    if totalSavings > 0 {
        return .smartCompress
    }

    return .analyzeOnly
}

private func makeSummary(groups: [FileGroupReport], savings: Int64) -> String {
    guard savings > 0 else { return "Files are already close to their practical minimum size." }
    let top = groups.max { $0.savings < $1.savings }
    if let top {
        return "\(top.kind.rawValue) carry the strongest saving opportunity."
    }
    return "Silica found a practical local compression path."
}
