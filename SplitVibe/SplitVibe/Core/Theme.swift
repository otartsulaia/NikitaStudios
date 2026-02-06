import SwiftUI

// MARK: - Design Tokens

enum Theme {
    // Corner radii
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 24
    static let cornerRadiusSmall: CGFloat = 10

    // Spacing
    static let padding: CGFloat = 16
    static let paddingSmall: CGFloat = 8
    static let paddingLarge: CGFloat = 24

    // Animation
    static let springAnimation = Animation.spring(duration: 0.5, bounce: 0.25)
    static let quickSpring = Animation.spring(duration: 0.3, bounce: 0.2)
    static let smoothAnimation = Animation.easeInOut(duration: 0.3)

    // Shadows
    static func cardShadow(_ color: Color = .black) -> some View {
        EmptyView()
    }

    // Gradient presets
    static let meshBackground = MeshGradient(
        width: 3, height: 3,
        points: [
            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
        ],
        colors: [
            .black, Color(.systemBackground), .black,
            Color(.systemBackground), Color(red: 0.1, green: 0.05, blue: 0.15), Color(.systemBackground),
            .black, Color(.systemBackground), .black
        ]
    )
}

// MARK: - View Modifiers

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = Theme.cornerRadius

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct CardStyle: ViewModifier {
    let gradient: LinearGradient

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge, style: .continuous)
                    .fill(gradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge, style: .continuous)
                            .stroke(.white.opacity(0.15), lineWidth: 0.5)
                    )
            )
    }
}

struct FloatingBar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 0.5)
            )
    }
}

struct PanelToolbar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThickMaterial)
    }
}

// MARK: - Extensions

extension View {
    func glassBackground(cornerRadius: CGFloat = Theme.cornerRadius) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }

    func cardStyle(gradient: LinearGradient) -> some View {
        modifier(CardStyle(gradient: gradient))
    }

    func floatingBar() -> some View {
        modifier(FloatingBar())
    }

    func panelToolbar() -> some View {
        modifier(PanelToolbar())
    }

    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - Haptics Helper

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
