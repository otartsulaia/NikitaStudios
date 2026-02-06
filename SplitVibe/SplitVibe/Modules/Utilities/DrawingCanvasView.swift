import SwiftUI
import PencilKit

struct DrawingCanvasView: View {
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor: Color = .white
    @State private var brushSize: CGFloat = 5

    private let colors: [Color] = [.white, .red, .orange, .yellow, .green, .blue, .purple, .pink]

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 8) {
                Image(systemName: "paintbrush.fill")
                    .foregroundStyle(.pink)
                    .font(.caption)

                // Color picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 22, height: 22)
                                .overlay {
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 2 : 0)
                                }
                                .onTapGesture {
                                    selectedColor = color
                                    updateTool()
                                }
                        }
                    }
                }

                Spacer()

                // Eraser
                Button {
                    canvasView.tool = PKEraserTool(.bitmap)
                } label: {
                    Image(systemName: "eraser.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Clear
                Button {
                    canvasView.drawing = PKDrawing()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            // Canvas
            CanvasRepresentable(canvasView: $canvasView)
                .onAppear {
                    updateTool()
                    canvasView.backgroundColor = .black
                    canvasView.drawingPolicy = .anyInput
                }
        }
    }

    private func updateTool() {
        let uiColor = UIColor(selectedColor)
        canvasView.tool = PKInkingTool(.pen, color: uiColor, width: brushSize)
    }
}

struct CanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
