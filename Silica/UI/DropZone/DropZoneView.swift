import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    var title = "Drop anything"
    var subtitle = "Silica will find the best way."
    var minHeight: CGFloat = 280
    var onFiles: ([URL]) -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 88, height: 88)
                    .overlay {
                        Image(systemName: "capsule.lefthalf.filled")
                            .font(.system(size: 36, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                    }
                    .shadow(color: .blue.opacity(isTargeted ? 0.24 : 0.1), radius: isTargeted ? 30 : 16)
            }

            VStack(spacing: 6) {
                Text(title)
                    .font(.title2.weight(.semibold))
                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: minHeight)
        .background {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8, 8]))
                        .foregroundStyle(isTargeted ? .blue.opacity(0.75) : .secondary.opacity(0.22))
                }
        }
        .scaleEffect(isTargeted ? 1.015 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: isTargeted)
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
            Task {
                let urls = await providers.asyncFileURLs()
                if !urls.isEmpty {
                    await MainActor.run { onFiles(urls) }
                }
            }
            return true
        }
    }
}

private extension Array where Element == NSItemProvider {
    func asyncFileURLs() async -> [URL] {
        await withTaskGroup(of: URL?.self) { group in
            for provider in self {
                group.addTask {
                    await provider.fileURL()
                }
            }

            var urls: [URL] = []
            for await url in group {
                if let url { urls.append(url) }
            }
            return urls
        }
    }
}

private extension NSItemProvider {
    func fileURL() async -> URL? {
        await withCheckedContinuation { continuation in
            loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                if let data = item as? Data {
                    continuation.resume(returning: URL(dataRepresentation: data, relativeTo: nil))
                } else if let url = item as? URL {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
