import SwiftUI
import PencilKit

struct DrawingCanvasView: View {
    @State private var canvasView = PKCanvasView()
    @State private var selectedColor: Color = .white
    @State private var brushSize: CGFloat = 5
    @State private var activeTool: DrawingTool = .pen

    private let colors: [Color] = [.white, .red, .orange, .yellow, .green, .blue, .purple, .pink]

    private enum DrawingTool: String, CaseIterable {
        case pen, eraser, clear

        var icon: String {
            switch self {
            case .pen: return "pencil.tip"
            case .eraser: return "eraser.fill"
            case .clear: return "trash"
            }
        }

        var label: String {
            switch self {
            case .pen: return "Pen"
            case .eraser: return "Eraser"
            case .clear: return "Clear"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Glass Toolbar
            VStack(spacing: 10) {
                // Color swatches row
                HStack(spacing: 0) {
                    Image(systemName: "paintbrush.fill")
                        .foregroundStyle(.pink)
                        .font(.subheadline.weight(.semibold))
                        .padding(.trailing, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color.gradient)
                                    .frame(width: 26, height: 26)
                                    .overlay {
                                        // Inner ring when selected
                                        Circle()
                                            .stroke(Color.black.opacity(0.6), lineWidth: selectedColor == color ? 2.5 : 0)
                                            .padding(4)
                                    }
                                    .overlay {
                                        Circle()
                                            .stroke(Color.white.opacity(selectedColor == color ? 0.9 : 0), lineWidth: 2)
                                    }
                                    .scaleEffect(selectedColor == color ? 1.15 : 1.0)
                                    .animation(.spring(duration: 0.3, bounce: 0.4), value: selectedColor == color)
                                    .onTapGesture {
                                        Haptics.selection()
                                        selectedColor = color
                                        activeTool = .pen
                                        updateTool()
                                    }
                            }
                        }
                    }
                }

                // Brush size slider + tool buttons
                HStack(spacing: 12) {
                    // Brush size indicator
                    Circle()
                        .fill(.white)
                        .frame(width: max(4, brushSize), height: max(4, brushSize))
                        .frame(width: 20, height: 20)

                    Slider(value: $brushSize, in: 1...30, step: 1)
                        .tint(.pink)
                        .frame(maxWidth: .infinity)
                        .onChange(of: brushSize) {
                            updateTool()
                        }

                    Spacer().frame(width: 4)

                    // Tool buttons as glass pills
                    ForEach(DrawingTool.allCases, id: \.self) { tool in
                        Button {
                            Haptics.tap()
                            activeTool = tool
                            switch tool {
                            case .pen:
                                updateTool()
                            case .eraser:
                                canvasView.tool = PKEraserTool(.bitmap)
                            case .clear:
                                canvasView.drawing = PKDrawing()
                                activeTool = .pen
                                updateTool()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: tool.icon)
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundStyle(activeTool == tool ? .white : .secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(activeTool == tool ? .white.opacity(0.15) : .white.opacity(0.05))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(activeTool == tool ? 0.2 : 0.08), lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)

            // MARK: - Canvas
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
