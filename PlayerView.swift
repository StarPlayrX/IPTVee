//
// From SwiftUI by Example by Paul Hudson
// https://www.hackingwithswift.com/quick-start/swiftui
//
// You're welcome to use this code for any purpose,
// commercial or otherwise, with or without attribution.
//

import AVKit
import SwiftUI
import WebKit

struct Webview : UIViewRepresentable {
    let request: URLRequest
    var webview: WKWebView?

    init(web: WKWebView?, req: URLRequest) {
        self.webview = WKWebView()
        self.request = req
    }

    class Coordinator: NSObject, WKUIDelegate {
        var parent: Webview

        init(_ parent: Webview) {
            self.parent = parent
        }

        // Delegate methods go here

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            print("HELLO")
            // alert functionality goes here

        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView  {
        return webview!
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.uiDelegate = context.coordinator
        uiView.load(request)
    }

    func reload(){
        webview?.reload()
    }
}

struct PlayerView: View {

    let webview = Webview(web: nil, req: URLRequest(url: URL(string: "http://primestreams.tv:826/live/toddbruss90/zzeH7C0xdw/36593.m3u8")!))

    var body: some View {
        VStack {
            webview
            HStack() {
            
                Button(action: {
                    self.webview.reload()
                }){
                    Image(systemName: "arrow.clockwise")
                }.padding(32)

              
            }.frame(height: 40)
        }.onAppear(perform: {})
    }
}



/*struct PlayerView2: View {
   // let toPresent = UIHostingController(rootView: AnyView(EmptyView()))
    @State private var vURL = URL(string: "http://primestreams.tv:826/live/toddbruss90/zzeH7C0xdw/36593.m3u8")
    var body: some View {
    
            //    WebView(request: URLRequest(url: URL(string: "https://www.apple.com")!))
                // ... other your content below

              //  CustomPlayer(src: "http://primestreams.tv:826/live/toddbruss90/zzeH7C0xdw/36593.m3u8")
             //   Spacer()

              
            

        }


}

struct CustomPlayer: UIViewControllerRepresentable {
 let src: String

 func makeUIViewController(context: UIViewControllerRepresentableContext<CustomPlayer>) -> AVPlayerViewController {
   let controller = AVPlayerViewController()
   let player = AVPlayer(url: URL(string: src)!)
   controller.player = player
     controller.exitsFullScreenWhenPlaybackEnds = true
   player.play()
   return controller
 }

 func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<CustomPlayer>) { }
}*/

