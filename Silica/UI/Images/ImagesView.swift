import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct ImagesView: View {
    @EnvironmentObject private var appState: AppState
    @State private var quality = 0.82
    @State private var maxWidth = 1920.0
    @State private var maxHeight = 1920.0
    @State private var removeMetadata = true
    @State private var removeGPS = true
    @State private var outputFormat: ImageOutputFormat = .jpeg
    @State private var showImporter = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ScreenHeader(title: "Images", subtitle: "Optimize screenshots, photos and batches for Telegram, websites or email.")

                HStack(alignment: .top, spacing: 22) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            DropZoneView(title: "Drop images here", subtitle: "PNG, JPEG, HEIC, WEBP, TIFF and GIF.") { urls in
                                appState.handleDroppedURLs(urls)
                                appState.selectedSection = .images
                            }
                            .frame(minHeight: 220)

                            HStack {
                                Button {
                                    showImporter = true
                                } label: {
                                    Label("Choose Images", systemImage: "photo.on.rectangle")
                                }
                                .controlSize(.large)

                                Button("Telegram") { applyTelegram() }
                                Button("Website") { applyWebsite() }
                                Button("Email") { applyEmail() }
                            }

                            SelectedFilesSummary()
                            ImagePreviewGrid(urls: imageURLs)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Optimization")
                                .font(.headline)

                            Picker("Output", selection: $outputFormat) {
                                ForEach(ImageOutputFormat.allCases) { format in
                                    Text(format.isAvailable ? format.displayName : "\(format.displayName) - unavailable").tag(format)
                                }
                            }

                            VStack(alignment: .leading) {
                                Text("Quality \(Int(quality * 100))%")
                                Slider(value: $quality, in: 0.35...1.0)
                            }

                            VStack(alignment: .leading) {
                                Text("Max width \(Int(maxWidth)) px")
                                Slider(value: $maxWidth, in: 800...4000, step: 20)
                            }

                            VStack(alignment: .leading) {
                                Text("Max height \(Int(maxHeight)) px")
                                Slider(value: $maxHeight, in: 800...4000, step: 20)
                            }

                            Toggle("Remove metadata", isOn: $removeMetadata)
                            Toggle("Remove GPS", isOn: $removeGPS)

                            SilicaPrimaryButton(title: "Optimize", symbolName: "wand.and.stars") {
                                Task {
                                    await appState.optimizeSelectedImages(
                                        quality: quality,
                                        maxWidth: Int(maxWidth),
                                        maxHeight: Int(maxHeight),
                                        outputFormat: outputFormat,
                                        removeMetadata: removeMetadata,
                                        removeGPS: removeGPS
                                    )
                                }
                            }
                        }
                    }
                    .frame(width: 360)
                }
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.image], allowsMultipleSelection: true) { result in
            if case .success(let urls) = result {
                appState.handleDroppedURLs(urls)
            }
        }
    }

    private var imageURLs: [URL] {
        appState.selectedURLs.filter { ["png", "jpg", "jpeg", "heic", "webp", "tiff", "gif"].contains($0.pathExtension.lowercased()) }
    }

    private func applyTelegram() {
        quality = 0.82
        maxWidth = 1920
        maxHeight = 1920
        removeMetadata = true
        removeGPS = true
        outputFormat = .jpeg
    }

    private func applyWebsite() {
        quality = 0.78
        maxWidth = 2400
        maxHeight = 2400
        removeMetadata = true
        removeGPS = true
        outputFormat = .webp
    }

    private func applyEmail() {
        quality = 0.76
        maxWidth = 1600
        maxHeight = 1600
        removeMetadata = true
        removeGPS = true
        outputFormat = .jpeg
    }
}

struct ImagePreviewGrid: View {
    let urls: [URL]
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .system

    private var copy: AppCopy { AppCopy(language: appLanguage) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(copy(.imagePreview))
                .font(.headline)

            if urls.isEmpty {
                Text(copy(.noPreview))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                    ForEach(urls.prefix(12), id: \.self) { url in
                        ImagePreviewTile(url: url)
                    }
                }
            }
        }
    }
}

struct ImagePreviewTile: View {
    let url: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                if let image = NSImage(contentsOf: url) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 96)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
