import AppKit
import Foundation

struct FinderService {
    func reveal(_ url: URL) {
        let manager = FileManager.default
        if manager.fileExists(atPath: url.path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
            return
        }

        let parent = url.deletingLastPathComponent()
        if manager.fileExists(atPath: parent.path) {
            NSWorkspace.shared.open(parent)
        }
    }

    func canReveal(_ url: URL?) -> Bool {
        guard let url else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
}
