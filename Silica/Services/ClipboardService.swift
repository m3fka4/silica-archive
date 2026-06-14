import AppKit
import Foundation

struct ClipboardService {
    func fileURLFromPasteboard() -> URL? {
        NSPasteboard.general.readObjects(forClasses: [NSURL.self], options: nil)?.first as? URL
    }
}
