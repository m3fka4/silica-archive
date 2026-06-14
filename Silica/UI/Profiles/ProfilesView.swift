import SwiftUI

struct ProfilesView: View {
    @EnvironmentObject private var appState: AppState
    @State private var editingProfile: CompressionProfile?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    ScreenHeader(title: "Profiles", subtitle: "Reusable compression recipes for daily workflows.")
                    Spacer()
                    Button {
                        appState.profiles.append(customProfile)
                    } label: {
                        Label("New Profile", systemImage: "plus")
                    }
                    .controlSize(.large)
                }

                LazyVStack(spacing: 12) {
                    ForEach($appState.profiles) { $profile in
                        ProfileCard(profile: profile) {
                            Task { await appState.run(profile: profile) }
                        } editAction: {
                            editingProfile = profile
                        }
                    }
                }
            }
        }
        .sheet(item: $editingProfile) { profile in
            ProfileEditorView(profile: binding(for: profile))
                .frame(width: 520, height: 620)
        }
    }

    private var customProfile: CompressionProfile {
        CompressionProfile(
            name: "Custom Profile",
            operation: .smartCompress,
            archiveFormat: .zip,
            compressionLevel: .balanced,
            imageQuality: 0.82,
            maxWidth: nil,
            maxHeight: nil,
            removeEXIF: true,
            removeGPS: true,
            destinationMode: .nextToOriginal,
            savesHistory: true,
            access: .free
        )
    }

    private func binding(for profile: CompressionProfile) -> Binding<CompressionProfile> {
        guard let index = appState.profiles.firstIndex(where: { $0.id == profile.id }) else {
            return .constant(profile)
        }

        return $appState.profiles[index]
    }
}

struct ProfileCard: View {
    let profile: CompressionProfile
    let runAction: () -> Void
    let editAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(profile.name, systemImage: profile.operation.symbolName)
                        .font(.headline)
                    Spacer()
                    Text(profile.access.rawValue.uppercased())
                        .font(.caption2.weight(.bold))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(profile.access == .pro ? .purple.opacity(0.18) : .blue.opacity(0.14), in: Capsule())
                }

                HStack(spacing: 10) {
                    Label(profile.archiveFormat.shortName, systemImage: "archivebox")
                    Label("\(Int(profile.imageQuality * 100))%", systemImage: "slider.horizontal.3")
                    Label(profile.compressionLevel.rawValue, systemImage: "speedometer")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    Label(profile.removeEXIF ? "EXIF removed" : "EXIF preserved", systemImage: "location.slash")
                    Label(profile.savesHistory ? "History enabled" : "No history", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                HStack {
                    Button("Run", action: runAction)
                    Button("Edit", action: editAction)
                }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.secondary.opacity(0.12))
        }
    }
}

struct ProfileEditorView: View {
    @Binding var profile: CompressionProfile
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Edit Profile")
                .font(.title2.weight(.semibold))

            Form {
                TextField("Name", text: $profile.name)

                Picker("Operation", selection: $profile.operation) {
                    ForEach(OperationKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }

                Picker("Archive format", selection: $profile.archiveFormat) {
                    ForEach(ArchiveFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }

                Picker("Compression level", selection: $profile.compressionLevel) {
                    ForEach(CompressionLevel.allCases) { level in
                        Text(level.displayName).tag(level)
                    }
                }

                Slider(value: $profile.imageQuality, in: 0.35...1.0) {
                    Text("Image quality")
                }

                Toggle("Remove EXIF", isOn: $profile.removeEXIF)
                Toggle("Remove GPS", isOn: $profile.removeGPS)

                Picker("Destination", selection: $profile.destinationMode) {
                    ForEach(DestinationMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }

                Toggle("Save history", isOn: $profile.savesHistory)
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
    }
}
