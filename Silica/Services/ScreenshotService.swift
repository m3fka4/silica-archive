import Foundation

struct ScreenshotService {
    func latestScreenshot() -> URL? {
        let desktop = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        guard let desktop else { return nil }

        let imageExtensions = Set(["png", "jpg", "jpeg", "heic"])
        let files = (try? FileManager.default.contentsOfDirectory(
            at: desktop,
            includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        return files
            .filter { url in
                let name = url.lastPathComponent.lowercased()
                return imageExtensions.contains(url.pathExtension.lowercased()) &&
                    (name.contains("screenshot") || name.contains("screen shot") || name.contains("снимок экрана"))
            }
            .sorted { lhs, rhs in
                let leftDate = (try? lhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                let rightDate = (try? rhs.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
                return leftDate > rightDate
            }
            .first
    }
}
