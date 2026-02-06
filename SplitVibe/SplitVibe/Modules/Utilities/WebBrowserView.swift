import SwiftUI
import WebKit

struct WebBrowserView: View {
    @State private var urlString = ""
    @State private var currentURL: URL?
    @State private var isLoading = false
    @State private var loadingProgress: Double = 0
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var webViewRef: WKWebView?

    private var isSecure: Bool {
        urlString.lowercased().hasPrefix("https")
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Glass URL Bar
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    // Lock icon for HTTPS
                    Image(systemName: currentURL != nil && isSecure ? "lock.fill" : "globe")
                        .foregroundStyle(currentURL != nil && isSecure ? .green : .blue)
                        .font(.caption.weight(.semibold))
                        .contentTransition(.symbolEffect(.replace))

                    TextField("Enter URL or search...", text: $urlString)
                        .textFieldStyle(.plain)
                        .font(.subheadline)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.go)
                        .onSubmit { navigate() }

                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    }

                    Button {
                        Haptics.tap()
                        navigate()
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)

                // Thin gradient progress line
                if isLoading {
                    GeometryReader { geo in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan, .mint],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * loadingProgress, height: 2)
                            .animation(.easeInOut(duration: 0.3), value: loadingProgress)
                    }
                    .frame(height: 2)
                }
            }
            .background(.ultraThinMaterial)

            // MARK: - Content
            if let url = currentURL {
                BrowserWebView(
                    url: url,
                    isLoading: $isLoading,
                    loadingProgress: $loadingProgress,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    webViewRef: $webViewRef
                )
            } else {
                // MARK: - Quick Links Landing
                VStack(spacing: 20) {
                    Text("Quick Links")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(1)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        quickLink("Reddit", icon: "bubble.left.fill", color: .orange, url: "https://reddit.com")
                        quickLink("Twitter/X", icon: "at", color: .blue, url: "https://x.com")
                        quickLink("Wikipedia", icon: "book.fill", color: .gray, url: "https://wikipedia.org")
                        quickLink("Google", icon: "magnifyingglass", color: .green, url: "https://google.com")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }

            // MARK: - Navigation Toolbar (when browsing)
            if currentURL != nil {
                HStack(spacing: 20) {
                    Button {
                        Haptics.tap()
                        webViewRef?.goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(canGoBack ? .primary : .quaternary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .disabled(!canGoBack)

                    Button {
                        Haptics.tap()
                        webViewRef?.goForward()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(canGoForward ? .primary : .quaternary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .disabled(!canGoForward)

                    Button {
                        Haptics.tap()
                        webViewRef?.reload()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    Spacer()

                    Button {
                        Haptics.tap()
                        currentURL = nil
                        urlString = ""
                        webViewRef = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
            }
        }
    }

    // MARK: - Quick Link Card

    private func quickLink(_ title: String, icon: String, color: Color, url: String) -> some View {
        Button {
            Haptics.tap()
            urlString = url
            navigate()
        } label: {
            HStack(spacing: 10) {
                // Gradient icon circle
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Circle()
                    )

                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Navigation

    private func navigate() {
        Haptics.tap()
        var input = urlString.trimmingCharacters(in: .whitespaces)
        if !input.contains("://") {
            if input.contains(".") {
                input = "https://" + input
            } else {
                input = "https://www.google.com/search?q=" + (input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? input)
            }
        }
        if let url = URL(string: input) {
            currentURL = url
        }
    }
}

// MARK: - Browser Web View

struct BrowserWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadingProgress: Double
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var webViewRef: WKWebView?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        context.coordinator.observe(webView)
        DispatchQueue.main.async {
            webViewRef = webView
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: BrowserWebView
        private var progressObservation: NSKeyValueObservation?
        private var backObservation: NSKeyValueObservation?
        private var forwardObservation: NSKeyValueObservation?

        init(_ parent: BrowserWebView) { self.parent = parent }

        func observe(_ webView: WKWebView) {
            progressObservation = webView.observe(\.estimatedProgress) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.loadingProgress = webView.estimatedProgress
                }
            }
            backObservation = webView.observe(\.canGoBack) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.canGoBack = webView.canGoBack
                }
            }
            forwardObservation = webView.observe(\.canGoForward) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.canGoForward = webView.canGoForward
                }
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
    }
}
