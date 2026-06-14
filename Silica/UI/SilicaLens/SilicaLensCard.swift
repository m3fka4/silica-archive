import SwiftUI

struct SilicaLensCard: View {
    let report: SilicaLensReport

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label("Silica Lens", systemImage: "camera.macro")
                        .font(.headline)
                    Spacer()
                    Text(report.recommendedAction.title)
                        .font(.caption.weight(.semibold))
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(.thinMaterial, in: Capsule())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Possible saving")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(ByteCountFormatter.silica.string(fromByteCount: report.estimatedSavings))
                        .font(.system(size: 42, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                }

                HStack {
                    MetricPill(title: "Original", value: ByteCountFormatter.silica.string(fromByteCount: report.originalSize), symbolName: "doc")
                    MetricPill(title: "Estimated", value: ByteCountFormatter.silica.string(fromByteCount: report.estimatedSize), symbolName: "arrow.down.forward")
                }

                VStack(spacing: 10) {
                    ForEach(report.fileGroups.prefix(4)) { group in
                        FileGroupRow(group: group)
                    }
                }

                Text(report.summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct FileGroupRow: View {
    let group: FileGroupReport

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: group.kind.symbolName)
                .frame(width: 26)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 3) {
                Text(group.kind.rawValue)
                    .font(.callout.weight(.medium))
                Text(group.advice)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("\(ByteCountFormatter.silica.string(fromByteCount: group.originalSize)) → \(ByteCountFormatter.silica.string(fromByteCount: group.estimatedSize))")
                .font(.caption.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
    }
}
