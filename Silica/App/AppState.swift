import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var selectedSection: SidebarSection = .smart
    @Published var selectedURLs: [URL] = []
    @Published var lensReport: SilicaLensReport = .mock
    @Published var recommendedAction: RecommendedAction = .smartCompress
    @Published var operationStatus: OperationStatus = .idle
    @Published var operationProgress: Double = 0
    @Published var currentOperationTitle = "Ready"
    @Published var profiles: [CompressionProfile] = CompressionProfile.defaults
    @Published var archivePreviewItems: [ArchiveItem] = []
    @Published var archiveStatusMessage = "Drop an archive to preview, test or extract."
    @Published var lastOutputURL: URL?
    @Published var lastSavedBytes: Int64 = 0

    let preferences = PreferencesService()
    let historyService = HistoryService()
    let screenshotService = ScreenshotService()
    let notificationService = NotificationService()

    private let analyzer = LocalSmartAnalyzer()
    private let archiveEngine = SystemArchiveEngine()
    private let imageOptimizer = SystemImageOptimizer()

    var menuBarSystemImage: String {
        switch operationStatus {
        case .idle: "capsule"
        case .compressing: "capsule.inset.filled"
        case .done: "checkmark.circle"
        case .error: "exclamationmark.triangle"
        }
    }

    var hasSelectedArchive: Bool {
        selectedArchiveURL() != nil
    }

    func prepare() async {
        historyService.load()
        await notificationService.requestAuthorization()
    }

    func handleDroppedURLs(_ urls: [URL]) {
        selectedURLs = urls
        selectedSection = .smart
        Task {
            await analyzeSelectedFiles()
        }
    }

    func analyzeSelectedFiles() async {
        guard !selectedURLs.isEmpty else {
            lensReport = .mock
            recommendedAction = .smartCompress
            return
        }

        do {
            let report = try await analyzer.analyze(urls: selectedURLs)
            lensReport = report
            recommendedAction = report.recommendedAction
        } catch {
            operationStatus = .error
            currentOperationTitle = "Could not analyze files"
        }
    }

    func runMockOperation(kind: OperationKind) async {
        operationStatus = .compressing
        operationProgress = 0
        currentOperationTitle = kind.title
        lastOutputURL = nil
        lastSavedBytes = 0

        for step in 1...10 {
            try? await Task.sleep(for: .milliseconds(90))
            operationProgress = Double(step) / 10
        }

        let sourceSize = max(lensReport.originalSize, 148_000_000)
        let resultSize = max(lensReport.estimatedSize, 61_000_000)
        let item = OperationHistoryItem(
            date: .now,
            operation: kind,
            sourceSize: sourceSize,
            resultSize: resultSize,
            outputURL: URL(filePath: "\(NSHomeDirectory())/Downloads/Silica Result.zip"),
            usedProfileName: recommendedAction.title
        )

        if !preferences.privateModeByDefault && preferences.saveHistory {
            historyService.add(item)
        }

        operationStatus = .done
        currentOperationTitle = "Done"
        lastOutputURL = nil
        lastSavedBytes = item.savedBytes
        scheduleHUDDismiss()
        await sendOperationFinishedNotification(savedBytes: item.savedBytes)
    }

    func runSmartAction() async {
        guard !selectedURLs.isEmpty else {
            selectedSection = .smart
            await runMockOperation(kind: .smartCompress)
            return
        }

        switch recommendedAction {
        case .optimizeImages:
            await optimizeSelectedImages(
                quality: preferences.defaultImageQuality,
                maxWidth: preferences.defaultImageMaxWidth,
                maxHeight: preferences.defaultImageMaxHeight,
                outputFormat: .jpeg,
                removeMetadata: preferences.removeEXIFByDefault,
                removeGPS: preferences.removeGPSByDefault
            )
        case .extractArchive:
            await extractSelectedArchive()
        case .createZip, .smartCompress:
            await createArchive(
                format: preferences.defaultArchiveFormat,
                level: preferences.defaultCompressionLevel,
                password: nil,
                preserveFolders: true,
                splitSizeMB: nil
            )
        case .analyzeOnly:
            await analyzeSelectedFiles()
        case .skip:
            operationStatus = .done
            currentOperationTitle = "Nothing to compress"
            lastOutputURL = nil
            scheduleHUDDismiss()
        }
    }

    func createArchive(format: ArchiveFormat, level: CompressionLevel, password: String?, preserveFolders: Bool, splitSizeMB: Int?) async {
        guard !selectedURLs.isEmpty else {
            await runMockOperation(kind: .archiveCompression)
            return
        }

        operationStatus = .compressing
        operationProgress = 0.12
        currentOperationTitle = "Compressing..."
        lastOutputURL = nil
        lastSavedBytes = 0

        do {
            let destination = uniqueFileURL(
                downloadsFolder().appendingPathComponent("\(archiveBaseName()).\(format.fileExtension)")
            )

            let options = CompressionOptions(
                level: level,
                password: password?.isEmpty == false ? password : nil,
                preserveFolderStructure: preserveFolders,
                splitSizeMB: splitSizeMB
            )

            try await archiveEngine.createArchive(files: selectedURLs, destinationURL: destination, format: format, options: options)
            operationProgress = 1
            await completeRealOperation(kind: .archiveCompression, outputURL: destination)
        } catch {
            operationStatus = .error
            currentOperationTitle = error.localizedDescription
            await sendErrorNotification(title: "Couldn’t create archive", body: error.localizedDescription)
        }
    }

    func previewSelectedArchive() async {
        guard let archive = selectedArchiveURL() else {
            archiveStatusMessage = "Select an archive first."
            return
        }

        do {
            archivePreviewItems = try await archiveEngine.listContents(archiveURL: archive)
            archiveStatusMessage = "Previewing \(archive.lastPathComponent)"
        } catch {
            archivePreviewItems = []
            archiveStatusMessage = error.localizedDescription
        }
    }

    func testSelectedArchive() async {
        guard let archive = selectedArchiveURL() else {
            archiveStatusMessage = "Select an archive first."
            return
        }

        operationStatus = .compressing
        currentOperationTitle = "Testing archive..."
        operationProgress = 0.35
        lastOutputURL = nil

        do {
            let result = try await archiveEngine.testArchive(archiveURL: archive)
            operationProgress = 1
            operationStatus = .done
            currentOperationTitle = "Archive OK"
            archiveStatusMessage = result.message
            scheduleHUDDismiss()
        } catch {
            operationStatus = .error
            currentOperationTitle = "Archive test failed"
            archiveStatusMessage = error.localizedDescription
            await sendErrorNotification(title: "Couldn’t test archive", body: error.localizedDescription)
        }
    }

    func extractSelectedArchive() async {
        guard let archive = selectedArchiveURL() else {
            archiveStatusMessage = "Select an archive first."
            return
        }

        operationStatus = .compressing
        currentOperationTitle = "Extracting..."
        operationProgress = 0.18
        lastOutputURL = nil
        lastSavedBytes = 0

        do {
            let destination = downloadsFolder()
                .appendingPathComponent(archive.deletingPathExtension().lastPathComponent, isDirectory: true)
            let finalDestination = uniqueDestinationFolder(destination)
            try await archiveEngine.extract(archiveURL: archive, destinationURL: finalDestination)
            operationProgress = 1
            archiveStatusMessage = "Extracted to \(finalDestination.path)"
            await completeRealOperation(kind: .extraction, outputURL: finalDestination)
        } catch {
            operationStatus = .error
            currentOperationTitle = "Couldn’t extract archive"
            archiveStatusMessage = error.localizedDescription
            await sendErrorNotification(title: "Couldn’t extract this archive", body: error.localizedDescription)
        }
    }

    func optimizeSelectedImages(quality: Double, maxWidth: Int?, maxHeight: Int?, outputFormat: ImageOutputFormat, removeMetadata: Bool, removeGPS: Bool) async {
        let images = selectedURLs.filter { ["png", "jpg", "jpeg", "heic", "webp", "tiff", "gif"].contains($0.pathExtension.lowercased()) }
        guard !images.isEmpty else {
            await runMockOperation(kind: .imageOptimization)
            return
        }

        operationStatus = .compressing
        operationProgress = 0.10
        currentOperationTitle = "Optimizing images..."
        lastOutputURL = nil
        lastSavedBytes = 0

        do {
            let outputFolder = downloadsFolder().appendingPathComponent("Silica Optimized", isDirectory: true)
            let options = ImageOptimizationOptions(
                quality: quality,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                outputFormat: outputFormat,
                removeMetadata: removeMetadata,
                removeGPS: removeGPS,
                preserveOriginal: true,
                suffix: "-silica",
                destinationFolder: outputFolder
            )

            let results = try await imageOptimizer.batchOptimize(inputURLs: images, outputFolder: outputFolder, options: options)
            operationProgress = 1
            let sourceSize = results.reduce(Int64(0)) { $0 + $1.originalSize }
            let resultSize = results.reduce(Int64(0)) { $0 + $1.outputSize }
            await completeRealOperation(kind: .imageOptimization, outputURL: outputFolder, sourceSize: sourceSize, resultSize: resultSize)
        } catch {
            operationStatus = .error
            currentOperationTitle = error.localizedDescription
            await sendErrorNotification(title: "Couldn’t optimize images", body: error.localizedDescription)
        }
    }

    func compressLatestScreenshot() async {
        guard let screenshot = screenshotService.latestScreenshot() else {
            operationStatus = .error
            currentOperationTitle = "No recent screenshot"
            await sendErrorNotification(title: "No recent screenshot", body: "Silica could not find a screenshot on your Desktop.")
            return
        }

        selectedURLs = [screenshot]
        await analyzeSelectedFiles()
        await optimizeSelectedImages(quality: 0.82, maxWidth: 1920, maxHeight: 1920, outputFormat: .jpeg, removeMetadata: true, removeGPS: true)
    }

    func compressClipboardFile() async {
        guard let file = ClipboardService().fileURLFromPasteboard() else {
            operationStatus = .error
            currentOperationTitle = "No clipboard file"
            return
        }

        selectedURLs = [file]
        await analyzeSelectedFiles()
        await createArchive(format: .zip, level: .fast, password: nil, preserveFolders: true, splitSizeMB: nil)
    }

    func compressLatestDownloadedFile() async {
        guard let file = latestFile(in: downloadsFolder()) else {
            operationStatus = .error
            currentOperationTitle = "No recent file"
            return
        }

        selectedURLs = [file]
        await analyzeSelectedFiles()
        await createArchive(format: .zip, level: .balanced, password: nil, preserveFolders: true, splitSizeMB: nil)
    }

    func run(profile: CompressionProfile) async {
        if profile.operation == .imageOptimization {
            await optimizeSelectedImages(
                quality: profile.imageQuality,
                maxWidth: profile.maxWidth,
                maxHeight: profile.maxHeight,
                outputFormat: .jpeg,
                removeMetadata: profile.removeEXIF,
                removeGPS: profile.removeGPS
            )
        } else {
            await createArchive(
                format: profile.archiveFormat,
                level: profile.compressionLevel,
                password: nil,
                preserveFolders: true,
                splitSizeMB: nil
            )
        }
    }

    func repeatOperation(_ item: OperationHistoryItem) async {
        switch item.operation {
        case .imageOptimization:
            await optimizeSelectedImages(
                quality: preferences.defaultImageQuality,
                maxWidth: preferences.defaultImageMaxWidth,
                maxHeight: preferences.defaultImageMaxHeight,
                outputFormat: .jpeg,
                removeMetadata: preferences.removeEXIFByDefault,
                removeGPS: preferences.removeGPSByDefault
            )
        case .archiveCompression, .smartCompress:
            await createArchive(
                format: preferences.defaultArchiveFormat,
                level: preferences.defaultCompressionLevel,
                password: nil,
                preserveFolders: true,
                splitSizeMB: nil
            )
        case .extraction:
            await extractSelectedArchive()
        case .lensAnalysis:
            await analyzeSelectedFiles()
        }
    }

    func requestQuickPanel() {
        FloatingPanelService.shared.showQuickPanel(appState: self)
        NotificationCenter.default.post(name: .silicaOpenQuickPanel, object: nil)
    }

    private func completeRealOperation(kind: OperationKind, outputURL: URL, sourceSize: Int64? = nil, resultSize: Int64? = nil) async {
        guard FileManager.default.fileExists(atPath: outputURL.path) else {
            operationStatus = .error
            currentOperationTitle = "Result was not created"
            lastOutputURL = nil
            lastSavedBytes = 0
            await sendErrorNotification(title: "Result was not created", body: "Silica finished the operation, but the output file could not be found.")
            scheduleHUDDismiss()
            return
        }

        let source = sourceSize ?? selectedURLs.reduce(Int64(0)) { $0 + fileSize($1) }
        let result = resultSize ?? fileSize(outputURL)
        let item = OperationHistoryItem(
            date: .now,
            operation: kind,
            sourceSize: source,
            resultSize: result,
            outputURL: outputURL,
            usedProfileName: recommendedAction.title
        )

        if !preferences.privateModeByDefault && preferences.saveHistory {
            historyService.add(item)
        }

        operationStatus = .done
        currentOperationTitle = "Done"
        lastOutputURL = outputURL
        lastSavedBytes = item.savedBytes
        scheduleHUDDismiss()
        await sendOperationFinishedNotification(savedBytes: item.savedBytes)
    }

    private func downloadsFolder() -> URL {
        FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first ?? URL(filePath: NSHomeDirectory()).appendingPathComponent("Downloads")
    }

    private func selectedArchiveURL() -> URL? {
        selectedURLs.first { ArchiveFormat.infer(from: $0) != nil || ["rar", "iso", "dmg"].contains($0.pathExtension.lowercased()) }
    }

    private func archiveBaseName() -> String {
        if selectedURLs.count == 1, let first = selectedURLs.first {
            let values = try? first.resourceValues(forKeys: [.isDirectoryKey])
            let rawName = values?.isDirectory == true ? first.lastPathComponent : first.deletingPathExtension().lastPathComponent
            return sanitizedFileName(rawName.isEmpty ? "Silica Archive" : rawName)
        }

        if let parent = selectedURLs.first?.deletingLastPathComponent().lastPathComponent, !parent.isEmpty {
            return sanitizedFileName(parent)
        }

        return "Silica Archive"
    }

    private func sanitizedFileName(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:?%*|\"<>")
        return name.components(separatedBy: invalid).joined(separator: "-")
    }

    private static func fileStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: .now)
    }

    private func fileSize(_ url: URL) -> Int64 {
        if let values = try? url.resourceValues(forKeys: [.isDirectoryKey]), values.isDirectory == true {
            let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles])
            return enumerator?.compactMap { $0 as? URL }.reduce(Int64(0)) { total, child in
                total + fileSize(child)
            } ?? 0
        }

        return (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init) ?? 0
    }

    private func uniqueDestinationFolder(_ folder: URL) -> URL {
        var candidate = folder
        var index = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = folder.deletingLastPathComponent().appendingPathComponent("\(folder.lastPathComponent) \(index)", isDirectory: true)
            index += 1
        }
        return candidate
    }

    private func uniqueFileURL(_ url: URL) -> URL {
        var candidate = url
        let base = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        var index = 2

        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = url.deletingLastPathComponent().appendingPathComponent("\(base) \(index).\(ext)")
            index += 1
        }

        return candidate
    }

    private func latestFile(in folder: URL) -> URL? {
        let files = (try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        return files
            .filter { url in
                let values = try? url.resourceValues(forKeys: [.isRegularFileKey])
                return values?.isRegularFile == true
            }
            .sorted { lhs, rhs in
                let leftDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                let rightDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                return leftDate > rightDate
            }
            .first
    }

    func dismissHUD() {
        guard operationStatus != .compressing else { return }
        operationStatus = .idle
        currentOperationTitle = "Ready"
    }

    private func scheduleHUDDismiss() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(4))
            dismissHUD()
        }
    }

    private func sendOperationFinishedNotification(savedBytes: Int64) async {
        guard preferences.showNotifications else { return }
        await notificationService.sendOperationFinished(savedBytes: savedBytes)
    }

    private func sendErrorNotification(title: String, body: String) async {
        guard preferences.showNotifications else { return }
        await notificationService.sendError(title: title, body: body)
    }
}

enum OperationStatus {
    case idle
    case compressing
    case done
    case error
}

extension Notification.Name {
    static let silicaOpenQuickPanel = Notification.Name("silicaOpenQuickPanel")
}
