import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @AppStorage("appearance") private var appearance: AppearancePreference = .system
    @AppStorage("accent") private var accent: AccentPreference = .blue
    @AppStorage("appLanguage") private var appLanguage: AppLanguage = .system
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("interfaceSize") private var interfaceSize: InterfaceSizePreference = .comfortable

    private var copy: AppCopy { AppCopy(language: appLanguage) }

    var body: some View {
        NavigationSplitView {
            List(SidebarSection.allCases, selection: $appState.selectedSection) { section in
                Label(section.title(language: appLanguage), systemImage: section.symbolName)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 210)
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lock.shield")
                        Text(copy(.everythingLocal))
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
            }
        } detail: {
            ZStack {
                SilicaBackground()
                content
                    .padding(28)
                VStack {
                    ActivityHUD()
                        .environmentObject(appState)
                    Spacer()
                }
                .padding(.top, 18)
            }
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        openWindow(id: AppRouter.quickPanelID)
                    } label: {
                        Label("Quick Panel", systemImage: "command")
                    }

                    Button {
                        Task { await appState.runSmartAction() }
                    } label: {
                        Label("Start", systemImage: "play.fill")
                    }
                    .disabled(appState.operationStatus == .compressing)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .silicaOpenQuickPanel)) { _ in
                openWindow(id: AppRouter.quickPanelID)
            }
        }
        .preferredColorScheme(appearance.colorScheme)
        .tint(accent.color)
        .controlSize(interfaceSize.controlSize)
        .sheet(isPresented: Binding(get: { !onboardingComplete }, set: { if !$0 { onboardingComplete = true } })) {
            OnboardingView()
                .environmentObject(appState)
                .preferredColorScheme(appearance.colorScheme)
                .tint(accent.color)
                .frame(width: 620, height: 560)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch appState.selectedSection {
        case .smart:
            SmartView()
        case .archive:
            ArchiveView()
        case .images:
            ImagesView()
        case .lens:
            LensView()
        case .history:
            HistoryView()
        case .profiles:
            ProfilesView()
        case .settings:
            SettingsView()
        }
    }
}

struct SilicaBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color.blue.opacity(0.08),
                Color.purple.opacity(0.07),
                Color(nsColor: .windowBackgroundColor)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
