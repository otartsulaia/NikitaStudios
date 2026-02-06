import SwiftUI

struct NotesView: View {
    @State private var noteText = ""
    @State private var savedNotes: [String] = UserDefaults.standard.stringArray(forKey: "splitVibeNotes") ?? []
    @FocusState private var isEditing: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(.yellow)
                    .font(.caption)
                Text("Notes")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(noteText.count) chars")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            // Text editor
            TextEditor(text: $noteText)
                .font(.subheadline)
                .focused($isEditing)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.systemBackground))

            // Bottom bar
            HStack(spacing: 12) {
                Button {
                    if !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        savedNotes.insert(noteText, at: 0)
                        UserDefaults.standard.set(savedNotes, forKey: "splitVibeNotes")
                        noteText = ""
                        isEditing = false
                    }
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.caption.bold())
                        .foregroundStyle(.yellow)
                }

                Spacer()

                Button {
                    noteText = ""
                } label: {
                    Label("Clear", systemImage: "trash")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
        }
    }
}
