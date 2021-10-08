/* import SwiftUI
import WebKit

// This is on the back burner - Using AVPlayerViewController directly instead
struct Webview : UIViewRepresentable {
    @ObservedObject var plo = PlayerObservable.plo
    
    var wv = WKWebView()
    
    let loading = "Loading..."

    func makeCoordinator() -> Webview.Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        wv.navigationDelegate = context.coordinator
        wv.configuration.allowsInlineMediaPlayback = true
        wv.configuration.allowsPictureInPictureMediaPlayback = true
        wv.configuration.allowsAirPlayForMediaPlayback = true
        wv.configuration.mediaTypesRequiringUserActionForPlayback = .all
        wv.configuration.ignoresViewportScaleLimits = true
        return wv
    }
    
    func reload() {
        wv.reload()
        plo.isLoading = true
        plo.loadingMsg = "Loading..."
    }
    
    func loadURL(string: String) {
        wv.load(URLRequest(url: URL(string: string)!))
        
        plo.isLoading = true
        plo.loadingMsg = "Loading..."
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var plo = PlayerObservable.plo
        let locatingService = "Loading..."

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            plo.loadingMsg = locatingService
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            plo.loadingMsg = locatingService
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            plo.loadingMsg = error.localizedDescription
            
            if plo.loadingMsg.lowercased().contains("plug") {
                plo.isLoading = false
                plo.loadingMsg = ""
            }
        }
    }
}
*/
