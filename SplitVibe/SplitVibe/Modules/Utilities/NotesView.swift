import SwiftUI

struct NotesView: View {
    @State private var noteText = ""
    @State private var savedNotes: [String] = UserDefaults.standard.stringArray(forKey: "splitVibeNotes") ?? []
    @FocusState private var isEditing: Bool
    @State private var showSavedFeedback = false

    private let characterLimit = 5000

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Glass Toolbar
            HStack(spacing: 8) {
                Image(systemName: "note.text")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.yellow)
                    .symbolEffect(.pulse, options: .repeating.speed(0.3), value: showSavedFeedback)

                Text("Notes")
                    .font(.subheadline.bold())

                Spacer()

                // Character count pill
                Text("\(noteText.count) chars")
                    .font(.caption2.weight(.medium).monospacedDigit())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)

            // MARK: - Text Editor
            TextEditor(text: $noteText)
                .font(.subheadline)
                .focused($isEditing)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .padding(6)
                )
                .background(Color(.systemBackground))

            // MARK: - Bottom Action Bar
            HStack(spacing: 16) {
                // Save button - filled capsule with yellow tint
                Button {
                    if !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        savedNotes.insert(noteText, at: 0)
                        UserDefaults.standard.set(savedNotes, forKey: "splitVibeNotes")
                        noteText = ""
                        isEditing = false
                        Haptics.success()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSavedFeedback = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showSavedFeedback = false
                        }
                    }
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.caption.bold())
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.yellow.gradient)
                        )
                }
                .opacity(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1.0)

                Spacer()

                // Clear button - destructive text style
                Button(role: .destructive) {
                    noteText = ""
                } label: {
                    Label("Clear", systemImage: "trash")
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.8))
                }
                .opacity(noteText.isEmpty ? 0.3 : 0.8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
    }
}
