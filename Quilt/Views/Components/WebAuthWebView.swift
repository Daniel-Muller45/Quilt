import SwiftUI
import SwiftData
import WebKit

// MARK: - WebAuthWebView (WKWebView wrapper)

struct WebAuthWebView: UIViewRepresentable {
    let startURL: URL
    /// Your custom scheme (e.g., "quilt")
    let callbackScheme: String
    /// Called when the callback is hit (URL provided) or when you manually dismiss (nil)
    let onComplete: (URL?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let conf = WKWebViewConfiguration()
        // If portal requires cookies across domains, you may comment this out:
        // conf.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: conf)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        // Load the SnapTrade portal URL
        webView.load(URLRequest(url: startURL))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let parent: WebAuthWebView
        init(_ parent: WebAuthWebView) { self.parent = parent }

        // Intercept navigation to your app scheme (e.g., quilt://callback?...).
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            if let url = navigationAction.request.url {
                // Helpful logging while you integrate:
                print("➡️ WK navigating to:", url.absoluteString)

                if let scheme = url.scheme,
                   scheme.caseInsensitiveCompare(parent.callbackScheme) == .orderedSame {
                    // Hit the callback — report up and stop WebView navigation
                    parent.onComplete(url)
                    decisionHandler(.cancel)
                    return
                }
            }

            // Handle target=_blank inside same WKWebView
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationResponse: WKNavigationResponse,
                     decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let url = (navigationResponse.response as? HTTPURLResponse)?.url {
                print("⬅️ WK response URL:", url.absoluteString)
            }
            decisionHandler(.allow)
        }

        // Optional UI hooks
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WK didFail:", error.localizedDescription)
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WK didFailProvisional:", error.localizedDescription)
        }

        // Handle window.open/popups
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                let popup = WKWebView(frame: webView.bounds, configuration: configuration)
                popup.navigationDelegate = self
                popup.uiDelegate = self
                webView.addSubview(popup)
                return popup
            }
            return nil
        }
    }
}
