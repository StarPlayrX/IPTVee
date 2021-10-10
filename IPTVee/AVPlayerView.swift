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
 import iptvKit

 
 
struct AVPlayerView: UIViewControllerRepresentable {
    internal init(streamId: String) {
        self.streamId = streamId
    }
    
    @ObservedObject var plo = PlayerObservable.plo

    let streamId: String

    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        //playerViewController.player?.rate == 1 ? shouldEnterFullScreen(videoController) : shouldExitFullScreen(videoController)
    }
    
    func playNewStream(streamId: String, vc: AVPlayerViewController = PlayerObservable.plo.videoController) {
    
        guard
            let config = LoginObservable.shared.config,
            let user = config.userInfo.username,
            let pass = config.userInfo.password,
            let base = config.serverInfo.url,
            let port = config.serverInfo.port,
            
                //MARK: Todo - Build this dynamically using URL Components()
            let url = URL(string:"http://\(base):\(port)/live/\(user)/\(pass)/\(streamId).m3u8")
                
        else { return }
    
        plo.player.replaceCurrentItem(with: nil)
        vc.player = plo.player
        vc.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        vc.player?.volume = 1
        vc.player?.currentItem?.appliesPerFrameHDRDisplayMetadata = true
        vc.player?.currentItem?.preferredForwardBufferDuration = 1
        vc.player?.currentItem?.appliesPerFrameHDRDisplayMetadata = true
        vc.player?.currentItem?.preferredMaximumResolutionForExpensiveNetworks = CGSize.zero
        vc.player?.currentItem?.preferredPeakBitRateForExpensiveNetworks = 256
        vc.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        vc.player?.currentItem?.variantPreferences = .scalabilityToLosslessAudio
        vc.player?.currentItem?.startsOnFirstEligibleVariant = true
        vc.player?.currentItem?.automaticallyPreservesTimeOffsetFromLive = false
        vc.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        vc.player?.automaticallyWaitsToMinimizeStalling = false
        vc.player?.actionAtItemEnd = .pause
        vc.player?.allowsExternalPlayback = true
        vc.player?.appliesMediaSelectionCriteriaAutomatically = true
        vc.player?.usesExternalPlaybackWhileExternalScreenIsActive = true
        vc.player?.preventsDisplaySleepDuringVideoPlayback = true
        vc.player?.externalPlaybackVideoGravity = .resizeAspectFill
        vc.player?.appliesMediaSelectionCriteriaAutomatically = true
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
       
        playNewStream(streamId: streamId)
        
        plo.videoController.allowsPictureInPicturePlayback = true
        plo.videoController.canStartPictureInPictureAutomaticallyFromInline = true
        plo.videoController.updatesNowPlayingInfoCenter = false
        plo.videoController.showsTimecodes = true
        plo.videoController.showsPlaybackControls = true
        plo.videoController.requiresLinearPlayback = false
        plo.videoController.entersFullScreenWhenPlaybackBegins = false
        plo.videoController.exitsFullScreenWhenPlaybackEnds = false
        
       // avSession()
        setupRemoteTransportControls()
        
        return plo.videoController
    }
    
    
  
}


func shouldEnterFullScreen(_ videoController: AVPlayerViewController = PlayerObservable.plo.videoController, ride: Bool = false) {
    if videoController.entersFullScreenWhenPlaybackBegins || ride {
        let selector = NSSelectorFromString("_transitionToFullScreenAnimated:interactive:completionHandler:")
        if videoController.responds(to: selector) {
            videoController.perform(selector, with: true, with: nil)
        }
    }
}

 
 

 
 
func shouldExitFullScreen(_ videoController: AVPlayerViewController) {
    if videoController.exitsFullScreenWhenPlaybackEnds {
        let selector = NSSelectorFromString("_transitionFromFullScreenAnimated:interactive:completionHandler:")
        if videoController.responds(to: selector) {
            videoController.perform(selector, with: true, with: nil)
        }
    }
}

func avSession() {
    let avSession = AVAudioSession.sharedInstance()
    
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

func setupRemoteTransportControls(videoController: AVPlayerViewController = PlayerObservable.plo.videoController ) {
*/







