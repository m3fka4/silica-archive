import SwiftUI

struct LensView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ScreenHeader(title: "Silica Lens", subtitle: "A local explanation of where space can actually be saved.")

                HStack(alignment: .top, spacing: 22) {
                    VStack(spacing: 18) {
                        DropZoneView(title: "Drop files for Lens", subtitle: "Silica analyzes files locally and explains what is worth compressing.", minHeight: 190) { urls in
                            appState.handleDroppedURLs(urls)
                            appState.selectedSection = .lens
                        }

                        SilicaLensCard(report: appState.lensReport)
                    }
                    .frame(width: 460)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("How to use Silica Lens")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 10) {
                                LensStep(number: "1", title: "Drop files or folders", detail: "Use any mix of images, documents, archives and folders.")
                                LensStep(number: "2", title: "Read the saving map", detail: "Lens shows what can shrink, what is already compressed and what should be skipped.")
                                LensStep(number: "3", title: "Run the recommended action", detail: "Use Smart Compress, Optimize Images or Extract based on the report.")
                            }

                            Divider()

                            Text("Recommended action")
                                .font(.headline)

                            Label(appState.lensReport.recommendedAction.title, systemImage: appState.lensReport.recommendedAction.symbolName)
                                .font(.title2.weight(.semibold))

                            Text("The MVP analyzer uses local file type, extension, folder expansion, size and compression heuristics. It is intentionally explainable and offline.")
                                .font(.callout)
                                .foregroundStyle(.secondary)

                            Divider()

                            ForEach(appState.lensReport.fileGroups) { group in
                                FileGroupRow(group: group)
                            }

                            SilicaPrimaryButton(title: "Smart Compress", symbolName: "sparkles") {
                                Task { await appState.runSmartAction() }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LensStep: View {
    let number: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.weight(.bold))
                .frame(width: 24, height: 24)
                .background(.thinMaterial, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.callout.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
