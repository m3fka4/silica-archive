import SwiftUI
import UniformTypeIdentifiers

struct SmartView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showImporter = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top, spacing: 26) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Compress smarter.")
                                .font(.system(size: 46, weight: .semibold, design: .rounded))
                            Text("Drop anything. Silica will find the best way.")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        DropZoneView(title: "Drop files or folders here", subtitle: "Silica will analyze archives, images and everyday files.") { urls in
                            appState.handleDroppedURLs(urls)
                        }

                        HStack {
                            SilicaPrimaryButton(title: "Choose Files", symbolName: "plus") {
                                showImporter = true
                            }

                            Button {
                                appState.selectedSection = .lens
                            } label: {
                                Label("Analyze with Silica Lens", systemImage: "camera.macro")
                            }
                            .controlSize(.large)
                        }
                    }

                    VStack(spacing: 18) {
                        SilicaLensCard(report: appState.lensReport)
                        SmartRecommendationCard()
                    }
                    .frame(width: 420)
                }

                RecentOperationsStrip()
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            if case .success(let urls) = result {
                appState.handleDroppedURLs(urls)
            }
        }
    }
}

struct SmartRecommendationCard: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Label("Recommended action", systemImage: appState.recommendedAction.symbolName)
                    .font(.headline)

                Text(appState.recommendedAction.title)
                    .font(.title2.weight(.semibold))

                Text("Silica picks a local workflow based on file type, size, estimated recompression value and privacy settings.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                SilicaPrimaryButton(title: "Start", symbolName: "play.fill") {
                    Task { await appState.runSmartAction() }
                }
            }
        }
    }
}

struct RecentOperationsStrip: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent")
                .font(.title3.weight(.semibold))

            HStack(spacing: 14) {
                ForEach(appState.historyService.items.prefix(3)) { item in
                    GlassCard(padding: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label(item.operation.title, systemImage: item.operation.symbolName)
                                .font(.callout.weight(.semibold))
                            Text("Saved \(ByteCountFormatter.silica.string(fromByteCount: item.savedBytes))")
                                .font(.title3.weight(.semibold))
                            Text(DateFormatter.silicaHistory.string(from: item.date))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}
