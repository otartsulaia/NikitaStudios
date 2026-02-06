import SwiftUI
import WebKit

struct WebBrowserView: View {
    @State private var urlString = ""
    @State private var currentURL: URL?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            // URL bar
            HStack(spacing: 8) {
                Image(systemName: "globe")
                    .foregroundStyle(.blue)
                    .font(.caption)

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

                Button { navigate() } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            // Web content
            if let url = currentURL {
                BrowserWebView(url: url, isLoading: $isLoading)
            } else {
                VStack(spacing: 16) {
                    // Quick links
                    VStack(spacing: 8) {
                        Text("Quick Links")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            quickLink("Reddit", icon: "bubble.left.fill", color: .orange, url: "https://reddit.com")
                            quickLink("Twitter/X", icon: "at", color: .blue, url: "https://x.com")
                            quickLink("Wikipedia", icon: "book.fill", color: .gray, url: "https://wikipedia.org")
                            quickLink("Google", icon: "magnifyingglass", color: .green, url: "https://google.com")
                        }
                    }
                    .padding(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
    }

    private func quickLink(_ title: String, icon: String, color: Color, url: String) -> some View {
        Button {
            urlString = url
            navigate()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.caption)
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private func navigate() {
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

struct BrowserWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: BrowserWebView
        init(_ parent: BrowserWebView) { self.parent = parent }

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
