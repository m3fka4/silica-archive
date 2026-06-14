import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ScreenHeader(title: "Settings", subtitle: "Tune Silica without giving up local-first privacy.")

                GlassCard {
                    Form {
                        Section("General") {
                            Picker("Language", selection: appState.preferences.$appLanguage) {
                                ForEach(AppLanguage.allCases) { language in
                                    Text(language.rawValue).tag(language)
                                }
                            }
                            Button("Show initial setup again") {
                                appState.preferences.onboardingComplete = false
                            }
                            Picker("Save result to", selection: appState.preferences.$destinationMode) {
                                ForEach(DestinationMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            Toggle("Save history", isOn: appState.preferences.$saveHistory)
                            Toggle("Show notifications", isOn: appState.preferences.$showNotifications)
                        }

                        Section("Appearance") {
                            Picker("Appearance", selection: appState.preferences.$appearance) {
                                ForEach(AppearancePreference.allCases) { item in
                                    Text(item.rawValue).tag(item)
                                }
                            }
                            Picker("Accent", selection: appState.preferences.$accent) {
                                ForEach(AccentPreference.allCases) { item in
                                    Text(item.rawValue).tag(item)
                                }
                            }
                            Picker("Interface size", selection: appState.preferences.$interfaceSize) {
                                ForEach(InterfaceSizePreference.allCases) { item in
                                    Text(item.rawValue).tag(item)
                                }
                            }
                        }

                        Section("Finder") {
                            Toggle("Enable Finder actions", isOn: appState.preferences.$finderActionsEnabled)
                            Text("Finder Sync and Quick Actions are scaffolded for the full Xcode target.")
                                .foregroundStyle(.secondary)
                        }

                        Section("Menu Bar") {
                            Toggle("Show menu bar icon", isOn: appState.preferences.$showMenuBarIcon)
                            Toggle("Offer latest screenshot compression", isOn: appState.preferences.$offerScreenshotCompression)
                            Text("Menu Bar actions use the current selection when possible, otherwise they use the latest screenshot, clipboard file or Downloads file.")
                                .foregroundStyle(.secondary)
                        }

                        Section("Privacy") {
                            Toggle("Private Mode by default", isOn: appState.preferences.$privateModeByDefault)
                            Toggle("Remove EXIF by default", isOn: appState.preferences.$removeEXIFByDefault)
                            Toggle("Remove GPS by default", isOn: appState.preferences.$removeGPSByDefault)
                            Toggle("Warn before confidential files", isOn: appState.preferences.$warnBeforeSensitiveFiles)
                            Text("Everything stays on your Mac. Silica never uploads your files.")
                                .foregroundStyle(.secondary)
                        }

                        Section("Quick Panel") {
                            Toggle("Enable floating Quick Panel", isOn: appState.preferences.$quickPanelEnabled)
                            Picker("Keyboard shortcut", selection: appState.preferences.$quickPanelHotKey) {
                                ForEach(HotKeyPreference.allCases) { hotKey in
                                    Text(hotKey.displayName).tag(hotKey)
                                }
                            }
                            Toggle("Experimental MacBook notch positioning", isOn: appState.preferences.$experimentalNotchMode)
                            Text("When enabled, Silica opens the Quick Panel near the top-center display area. macOS does not allow third-party apps to truly live inside the notch, so this is a visual positioning mode.")
                                .foregroundStyle(.secondary)
                        }

                        Section("Compression") {
                            Picker("Default format", selection: appState.preferences.$defaultArchiveFormat) {
                                ForEach(ArchiveFormat.allCases) { format in
                                    Text(format.displayName).tag(format)
                                }
                            }
                            Picker("Default level", selection: appState.preferences.$defaultCompressionLevel) {
                                ForEach(CompressionLevel.allCases) { level in
                                    Text(level.displayName).tag(level)
                                }
                            }
                        }

                        Section("Images") {
                            Slider(value: appState.preferences.$defaultImageQuality, in: 0.35...1.0) {
                                Text("Default quality")
                            }
                            Stepper("Max width \(appState.preferences.defaultImageMaxWidth) px", value: appState.preferences.$defaultImageMaxWidth, in: 800...6000, step: 100)
                            Stepper("Max height \(appState.preferences.defaultImageMaxHeight) px", value: appState.preferences.$defaultImageMaxHeight, in: 800...6000, step: 100)
                        }

                        Section("Advanced") {
                            Toggle("Play completion sound", isOn: appState.preferences.$playCompletionSound)
                            Button("Clear History") {
                                appState.historyService.clear()
                            }
                        }
                    }
                    .formStyle(.grouped)
                    .frame(minHeight: 620)
                }
            }
        }
    }
}
