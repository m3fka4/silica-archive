import SwiftUI

struct ActivityHUD: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        if appState.operationStatus == .compressing || appState.operationStatus == .done {
            GlassCard(padding: 14) {
                HStack(spacing: 12) {
                    if appState.operationStatus == .done {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title2)
                            .frame(width: 24)
                    } else {
                        ProgressView(value: appState.operationProgress)
                            .progressViewStyle(.circular)
                            .frame(width: 24)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(appState.currentOperationTitle)
                            .font(.headline)
                        Text(appState.operationStatus == .done ? "Saved \(ByteCountFormatter.silica.string(fromByteCount: appState.lastSavedBytes))" : "\(Int(appState.operationProgress * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if appState.operationStatus == .done, let url = appState.lastOutputURL, FinderService().canReveal(url) {
                        Button("Show in Finder") {
                            FinderService().reveal(url)
                        }
                        .controlSize(.small)
                    }

                    Button {
                        appState.dismissHUD()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        } else if appState.operationStatus == .error {
            GlassCard(padding: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(appState.currentOperationTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Button {
                        appState.dismissHUD()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}
