//
//  AVPlayerView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/3/21.
//

import AVKit
import SwiftUI

struct AVPlayerView: UIViewControllerRepresentable {
    internal init(streamId: String, videoController: AVPlayerViewController? = AVPlayerViewController(), player: AVPlayer? = AVPlayer()) {
        self.streamId = streamId
        self.videoController = videoController!
        self.player = player!
    }
    
    @ObservedObject var plo = PlayerObservable.plo

    let streamId: String
    let videoController: AVPlayerViewController
    let player: AVPlayer
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        playerViewController.player?.rate == 1 ? shouldEnterFullScreen(videoController) : shouldExitFullScreen(videoController)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        guard let conf = LoginObservable.shared.config else { return videoController }
        
        let user = conf.userInfo.username
        let pass = conf.userInfo.password
        let url = conf.serverInfo.url
        let port = conf.serverInfo.port
 
        //MARK: Todo - Build this dynamically using URL Components()
        guard let url = URL(string:"http://\(url):\(port)/live/\(user)/\(pass)/\(streamId).m3u8") else { return videoController }

        if streamId == "HWS" {
            let stub = URL(string:"https://bit.ly/swswift")!
            player.replaceCurrentItem(with: AVPlayerItem(url: stub))
            player.playImmediately(atRate: 0.0)

        } else {
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
            player.playImmediately(atRate: 0.0)
        }
        
        videoController.player = player
        videoController.player?.usesExternalPlaybackWhileExternalScreenIsActive = true
        videoController.player?.appliesMediaSelectionCriteriaAutomatically = true
        videoController.player?.currentItem?.preferredForwardBufferDuration = 1
        videoController.player?.currentItem?.appliesPerFrameHDRDisplayMetadata = true
        videoController.player?.currentItem?.preferredMaximumResolutionForExpensiveNetworks = CGSize(width: 1920, height: 1080)
        videoController.player?.currentItem?.preferredPeakBitRateForExpensiveNetworks = 256
        videoController.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        videoController.player?.currentItem?.variantPreferences = .scalabilityToLosslessAudio
        videoController.player?.currentItem?.startsOnFirstEligibleVariant = false
        videoController.player?.preventsDisplaySleepDuringVideoPlayback = true
        videoController.player?.allowsExternalPlayback = true
        videoController.player?.externalPlaybackVideoGravity = .resizeAspectFill
        videoController.player?.actionAtItemEnd = .pause
        videoController.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        videoController.allowsPictureInPicturePlayback = true
        videoController.canStartPictureInPictureAutomaticallyFromInline = true
        videoController.updatesNowPlayingInfoCenter = true
        videoController.showsTimecodes = true
        videoController.showsPlaybackControls = true
        videoController.updatesNowPlayingInfoCenter = true
        videoController.requiresLinearPlayback = false
        videoController.loadViewIfNeeded()
        videoController.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        
        videoController.entersFullScreenWhenPlaybackBegins = false
        videoController.exitsFullScreenWhenPlaybackEnds = false
        videoController.player?.playImmediately(atRate: 1.0)
        videoController.player?.automaticallyWaitsToMinimizeStalling = true

        return videoController
    }
}

 func shouldEnterFullScreen(_ playerViewController: AVPlayerViewController) {
    if playerViewController.entersFullScreenWhenPlaybackBegins {
        let selector = NSSelectorFromString("_transitionToFullScreenAnimated:interactive:completionHandler:")
        if playerViewController.responds(to: selector) {
            playerViewController.perform(selector, with: true, with: nil)
        }
    }
}

func shouldExitFullScreen(_ playerViewController: AVPlayerViewController) {
    if playerViewController.exitsFullScreenWhenPlaybackEnds {
       let selector = NSSelectorFromString("_transitionFromFullScreenAnimated:interactive:completionHandler:")
       if playerViewController.responds(to: selector) {
           playerViewController.perform(selector, with: true, with: nil)
       }
   }
}
