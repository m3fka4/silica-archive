import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .system
    @AppStorage("appearance") private var appearance: AppearancePreference = .system
    @AppStorage("accent") private var accent: AccentPreference = .blue
    @AppStorage("defaultArchiveFormat") private var defaultArchiveFormat: ArchiveFormat = .zip
    @AppStorage("privateModeByDefault") private var privateModeByDefault = false
    @AppStorage("quickPanelEnabled") private var quickPanelEnabled = true
    @AppStorage("quickPanelHotKey") private var quickPanelHotKey: HotKeyPreference = .optionSpace
    @AppStorage("experimentalNotchMode") private var experimentalNotchMode = false
    @AppStorage("onboardingComplete") private var onboardingComplete = false

    private var copy: AppCopy { AppCopy(language: appLanguage) }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 16) {
                Image(systemName: "capsule.lefthalf.filled")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(accent.color)
                    .frame(width: 70, height: 70)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(copy(.onboardingTitle))
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                    Text(copy(.onboardingSubtitle))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            Form {
                Picker(copy(.language), selection: $appLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.rawValue).tag(language)
                    }
                }

                Picker(copy(.appearance), selection: $appearance) {
                    ForEach(AppearancePreference.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }

                Picker("Accent", selection: $accent) {
                    ForEach(AccentPreference.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }

                Picker(copy(.defaultFormat), selection: $defaultArchiveFormat) {
                    ForEach([ArchiveFormat.zip, .tarGzip, .sevenZ]) { format in
                        Text(format.displayName).tag(format)
                    }
                }

                Toggle(copy(.quickPanel) + " - Option Space", isOn: $quickPanelEnabled)
                Picker("Quick Panel shortcut", selection: $quickPanelHotKey) {
                    ForEach(HotKeyPreference.allCases) { hotKey in
                        Text(hotKey.displayName).tag(hotKey)
                    }
                }
                Toggle("Experimental notch positioning", isOn: $experimentalNotchMode)
                Toggle(copy(.privateMode), isOn: $privateModeByDefault)
            }
            .formStyle(.grouped)

            HStack {
                Button(copy(.skip)) {
                    onboardingComplete = true
                    dismiss()
                }

                Spacer()

                Button(copy(.finish)) {
                    onboardingComplete = true
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(28)
    }
}
