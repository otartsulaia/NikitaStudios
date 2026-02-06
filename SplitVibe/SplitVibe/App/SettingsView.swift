import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // MARK: - Persisted Settings

    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("autoplayVideos") private var autoplayVideos = true
    @AppStorage("backgroundAudio") private var backgroundAudio = true
    @AppStorage("soundEffects") private var soundEffects = true
    @AppStorage("defaultSplitRatio") private var defaultSplitRatio = "50/50"

    private let splitRatioOptions = ["30/70", "50/50", "70/30"]

    var body: some View {
        NavigationStack {
            List {
                // MARK: - General

                Section {
                    Picker(selection: $defaultSplitRatio) {
                        ForEach(splitRatioOptions, id: \.self) { ratio in
                            Text(ratio).tag(ratio)
                        }
                    } label: {
                        Label("Default Split Ratio", systemImage: "rectangle.split.1x2")
                    }

                    Toggle(isOn: $hapticFeedback) {
                        Label("Haptic Feedback", systemImage: "hand.tap")
                    }
                } header: {
                    Label("General", systemImage: "slider.horizontal.3")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }

                // MARK: - Media

                Section {
                    Toggle(isOn: $autoplayVideos) {
                        Label("Auto-play Videos", systemImage: "play.circle")
                    }

                    Toggle(isOn: $backgroundAudio) {
                        Label("Background Audio", systemImage: "speaker.wave.2")
                    }
                } header: {
                    Label("Media", systemImage: "play.rectangle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }

                // MARK: - Games

                Section {
                    Toggle(isOn: $soundEffects) {
                        Label("Sound Effects", systemImage: "speaker.badge.exclamationmark")
                    }

                    Label("High Scores", systemImage: "trophy")
                        .foregroundStyle(.primary)
                } header: {
                    Label("Games", systemImage: "gamecontroller.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                }

                // MARK: - About

                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Build", systemImage: "hammer")
                        Spacer()
                        Text(buildNumber)
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Made with care")
                                .foregroundStyle(.primary)
                            Text("NikitaStudios")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                    }
                } header: {
                    Label("About", systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(nil)
                } footer: {
                    Text("SplitVibe by NikitaStudios. All rights reserved.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                }
            }
            .tint(.purple)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Haptics.tap()
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }

    // MARK: - App Info Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
