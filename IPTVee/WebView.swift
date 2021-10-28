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


//
//  AVPlayerView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/3/21.
//

/*
import AVKit
import SwiftUI
import MediaPlayer

var avSession = AVAudioSession.sharedInstance()

public struct AVPlayerView: UIViewControllerRepresentable {
    public init(streamId: Int, hlsxPort: UInt16) {
        self.streamId = streamId
        self.hlsxPort = hlsxPort
    }
    
    let streamId: Int
    let hlsxPort: UInt16
    
    let lo = LoginObservable.shared
    let po = PlayerObservable.plo

    @ObservedObject var plo = PlayerObservable.plo
    
    public class Coordinator: NSObject, AVPlayerViewControllerDelegate, UINavigationControllerDelegate {
        let po = PlayerObservable.plo

        
        public func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            po.fullscreen = true
        }
        
        public func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            po.fullscreen = false
        }
        
        public func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
            po.pip = true
        }
        
        public func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
            po.pip = false
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public func updateUIViewController(_ videoController: AVPlayerViewController, context: Context) {}
    
    
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }

    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
   
        if streamId != po.previousStreamID {
            po.previousStreamID = streamId

            let good: String = lo.username
            let time: String = lo.password
            let todd: String = lo.config?.serverInfo.url ?? "primestreams.tv"
            let boss: String = lo.config?.serverInfo.port ?? "826"
            
            let primaryUrl = URL(string:"https://starplayrx.com:8888/\(todd)/\(boss)/\(good)/\(time)/\(streamId)/hlsx.m3u8")
            let backupUrl = URL(string:"http://localhost:\(hlsxPort)/\(streamId)/local.m3u8")
            let airplayUrl = URL(string:"http://\(todd):\(boss)/live/\(good)/\(time)/\(streamId).m3u8")
            
            plo.videoController.player?.replaceCurrentItem(with: nil)
            plo.videoController.player?.externalPlaybackVideoGravity = .resizeAspectFill
            plo.videoController.player?.preventsDisplaySleepDuringVideoPlayback = true
            plo.videoController.player?.usesExternalPlaybackWhileExternalScreenIsActive = true
            plo.videoController.player?.appliesMediaSelectionCriteriaAutomatically = true
            plo.videoController.player?.preventsDisplaySleepDuringVideoPlayback = true
            plo.videoController.player?.allowsExternalPlayback = true
            plo.videoController.player?.currentItem?.automaticallyHandlesInterstitialEvents = true
            plo.videoController.player?.currentItem?.seekingWaitsForVideoCompositionRendering = true
            plo.videoController.player?.currentItem?.appliesPerFrameHDRDisplayMetadata = true
            plo.videoController.player?.currentItem?.preferredForwardBufferDuration = 0
            plo.videoController.player?.currentItem?.automaticallyPreservesTimeOffsetFromLive = true
            plo.videoController.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            plo.videoController.player?.currentItem?.configuredTimeOffsetFromLive = .init(seconds: 120, preferredTimescale: 1000)
            plo.videoController.player?.currentItem?.startsOnFirstEligibleVariant = true
            plo.videoController.player?.currentItem?.variantPreferences = .scalabilityToLosslessAudio
            plo.videoController.player?.automaticallyWaitsToMinimizeStalling = false
            
            var streamUrl = primaryUrl
            
            DispatchQueue.global().async {
                if let url = URL(string: "https://starplayrx.com:8888/eHRybS5tM3U4") {
                    let hlsxm3u8 = Rest().textSync(url: url)
                    DispatchQueue.main.async {
                        let decodedString = (hlsxm3u8?.base64Decoded ?? "This is a really bad error.")
                        
                        if !(url.absoluteString).contains(decodedString) {
                            streamUrl = backupUrl
                        }
                    }
                }
            }
            
            let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true, AVURLAssetAllowsCellularAccessKey : true, AVURLAssetAllowsExpensiveNetworkAccessKey : true, AVURLAssetAllowsConstrainedNetworkAccessKey : true, AVURLAssetReferenceRestrictionsKey: true ]
            plo.videoController.player?.playImmediately(atRate: 1.0)
            
            if avSession.currentRoute.outputs.first?.portType == .airPlay ||  plo.videoController.player!.isExternalPlaybackActive  {
                streamUrl = airplayUrl
            }
        
            guard let streamUrl = streamUrl else { return  plo.videoController}
            
            print(streamUrl)
            
            let asset = AVURLAsset.init(url: streamUrl, options:options)
            let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            plo.videoController.player = AVPlayer(playerItem: playerItem)
            plo.videoController.player?.play()
            plo.videoController.delegate = context.coordinator
            plo.videoController.requiresLinearPlayback = false
            plo.videoController.showsPlaybackControls = true
            plo.videoController.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
            plo.videoController.canStartPictureInPictureAutomaticallyFromInline = true
        }
        
        return plo.videoController
    }
}

public func runAVSession() {
    do {
        avSession.accessibilityPerformMagicTap()
        avSession.accessibilityActivate()
        try avSession.setPreferredIOBufferDuration(0)
        try avSession.setCategory(.playback, mode: .moviePlayback, policy: .longFormVideo, options: [])
        try avSession.setActive(true)
    } catch {
        print(error)
    }

}
*/
