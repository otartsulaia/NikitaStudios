import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("General") {
                    Label("Default Split Ratio", systemImage: "rectangle.split.1x2")
                    Label("Haptic Feedback", systemImage: "hand.tap")
                }

                Section("Media") {
                    Label("Auto-play Videos", systemImage: "play.circle")
                    Label("Background Audio", systemImage: "speaker.wave.2")
                }

                Section("Games") {
                    Label("Sound Effects", systemImage: "speaker.badge.exclamationmark")
                    Label("High Scores", systemImage: "trophy")
                }

                Section("About") {
                    Label("Version 1.0", systemImage: "info.circle")
                    Label("Made by NikitaStudios", systemImage: "heart.fill")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
