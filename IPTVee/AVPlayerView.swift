//
//  AVPlayerView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/3/21.
//

import AVKit
import SwiftUI

struct AVPlayerView: UIViewControllerRepresentable {
    @ObservedObject var plo = PlayerObservable.plo

    let streamID: String
    let videoController: AVPlayerViewController
    let player: AVPlayer
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {}

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        guard let conf = LoginObservable.shared.config else { return AVPlayerViewController() }
        
        let user = conf.userInfo.username
        let pass = conf.userInfo.password
        let url = conf.serverInfo.url
        let port = conf.serverInfo.port
 
        //MARK: Todo - Build this dynamically using URL Components()
        guard let url = URL(string:"http://\(url):\(port)/live/\(user)/\(pass)/\(streamID).m3u8") else { return videoController }
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        videoController.player = player
        videoController.player?.currentItem?.preferredMaximumResolutionForExpensiveNetworks = CGSize(width: 1920, height: 1080)
        videoController.player?.currentItem?.preferredPeakBitRateForExpensiveNetworks = .infinity
        videoController.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        videoController.player?.currentItem?.startsOnFirstEligibleVariant = true
        videoController.player?.playImmediately(atRate: 0.0)
        videoController.player?.preventsDisplaySleepDuringVideoPlayback = true
        videoController.player?.allowsExternalPlayback = true
        videoController.player?.externalPlaybackVideoGravity = .resizeAspectFill
        videoController.player?.actionAtItemEnd = .pause
        videoController.player?.automaticallyWaitsToMinimizeStalling = true
        videoController.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        videoController.entersFullScreenWhenPlaybackBegins = false
        videoController.exitsFullScreenWhenPlaybackEnds = false
        videoController.allowsPictureInPicturePlayback = true
        videoController.canStartPictureInPictureAutomaticallyFromInline = true
        videoController.updatesNowPlayingInfoCenter = true
        videoController.showsTimecodes = true
        videoController.showsPlaybackControls = true
        videoController.updatesNowPlayingInfoCenter = true
        videoController.requiresLinearPlayback = false
        videoController.player?.playImmediately(atRate: 1.0)
       
        return videoController
        
    }
}

 func enterFullscreen(_ playerViewController: AVPlayerViewController) {

    if playerViewController.entersFullScreenWhenPlaybackBegins {
        let selectorToForceFullScreenMode = NSSelectorFromString("_transitionToFullScreenAnimated:interactive:completionHandler:")
        if playerViewController.responds(to: selectorToForceFullScreenMode) {
            playerViewController.perform(selectorToForceFullScreenMode, with: true, with: nil)
        }
    }
}
