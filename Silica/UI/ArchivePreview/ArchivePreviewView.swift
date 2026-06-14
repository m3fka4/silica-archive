import SwiftUI

struct ArchivePreviewView: View {
    let items: [ArchiveItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Archive Preview")
                .font(.headline)

            ForEach(items) { item in
                HStack {
                    Image(systemName: item.isDirectory ? "folder" : "doc")
                    Text(item.path)
                    Spacer()
                    Text(ByteCountFormatter.silica.string(fromByteCount: item.size))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
