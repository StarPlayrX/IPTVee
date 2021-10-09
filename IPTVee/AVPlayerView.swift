//
//  AVPlayerView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/3/21.
//

import AVKit
import SwiftUI
import MediaPlayer

let player = AVPlayer()
let videoController = AVPlayerViewController()

struct AVPlayerView: UIViewControllerRepresentable {
    internal init(streamId: String) {
        self.streamId = streamId
    }
    
    @ObservedObject var plo = PlayerObservable.plo
    
    let streamId: String

    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
        //playerViewController.player?.rate == 1 ? shouldEnterFullScreen(videoController) : shouldExitFullScreen(videoController)
    }
    
    func playNewStream(streamId: String, videoController: AVPlayerViewController) {
    
        guard
            let config = LoginObservable.shared.config,
            let user = config?.userInfo.username,
            let pass = config?.userInfo.password,
            let base = config?.serverInfo.url,
            let port = config?.serverInfo.port,
            
                //MARK: Todo - Build this dynamically using URL Components()
            let url = URL(string:"http://\(base):\(port)/live/\(user)/\(pass)/\(streamId).m3u8")
                
        else { return }
        
        player.replaceCurrentItem(with: nil)
        videoController.player = player
        videoController.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        videoController.player?.currentItem?.appliesPerFrameHDRDisplayMetadata = true
        videoController.player?.currentItem?.preferredForwardBufferDuration = 90
        videoController.player?.currentItem?.appliesPerFrameHDRDisplayMetadata = true
        videoController.player?.currentItem?.preferredMaximumResolutionForExpensiveNetworks = CGSize.zero
        videoController.player?.currentItem?.preferredPeakBitRateForExpensiveNetworks = 0
        videoController.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        videoController.player?.currentItem?.variantPreferences = .scalabilityToLosslessAudio
        videoController.player?.currentItem?.startsOnFirstEligibleVariant = true
        videoController.player?.currentItem?.automaticallyPreservesTimeOffsetFromLive = true
        videoController.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        videoController.player?.automaticallyWaitsToMinimizeStalling = true
        videoController.player?.actionAtItemEnd = .pause
        videoController.player?.allowsExternalPlayback = true
        videoController.player?.appliesMediaSelectionCriteriaAutomatically = true
        videoController.player?.usesExternalPlaybackWhileExternalScreenIsActive = true
        videoController.player?.preventsDisplaySleepDuringVideoPlayback = true
        videoController.player?.externalPlaybackVideoGravity = .resizeAspectFill
        videoController.player?.appliesMediaSelectionCriteriaAutomatically = true
        videoController.player?.playbackCoordinator.player?.play()
        
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        if !plo.isOkayToPlay {
            videoController.player?.pause()
            videoController.player = AVPlayer()
            return AVPlayerViewController()
        }
        
        plo.isOkayToPlay.toggle()

        playNewStream(streamId: streamId, videoController: videoController)
        
        videoController.allowsPictureInPicturePlayback = true
        videoController.canStartPictureInPictureAutomaticallyFromInline = true
        videoController.updatesNowPlayingInfoCenter = false
        videoController.showsTimecodes = false
        videoController.showsPlaybackControls = true
        videoController.requiresLinearPlayback = false
        videoController.entersFullScreenWhenPlaybackBegins = false
        videoController.exitsFullScreenWhenPlaybackEnds = false
        
       // avSession()
       setupRemoteTransportControls(videoController: videoController)
        
        return videoController
    }
    
    
    
}



func shouldEnterFullScreen(_ playerViewController: AVPlayerViewController, ride: Bool) {
    if playerViewController.entersFullScreenWhenPlaybackBegins || ride {
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



func setupRemoteTransportControls(videoController: AVPlayerViewController = AVPlayerViewController() ) {
    let commandCenter = MPRemoteCommandCenter.shared()
    let seekDuration: Float64 = 10
    
    commandCenter.accessibilityActivate()
    
    commandCenter.playCommand.addTarget(handler: { (event) in
        videoController.player?.play()
        return MPRemoteCommandHandlerStatus.success}
    )
    
    commandCenter.pauseCommand.addTarget(handler: { (event) in
        videoController.player?.pause()
        return MPRemoteCommandHandlerStatus.success}
    )
    
    commandCenter.skipBackwardCommand.addTarget(handler: { (event) in
        skipBackward()
        return MPRemoteCommandHandlerStatus.success}
    )
    
    commandCenter.skipForwardCommand.addTarget(handler: { (event) in
        skipForward()
        
        if let vcp = videoController.player, let ci = vcp.currentItem, (!ci.isPlaybackLikelyToKeepUp || ci.isPlaybackBufferEmpty) {
            skipBackward()
        }
        
        return MPRemoteCommandHandlerStatus.success}
    )
    
    commandCenter.togglePlayPauseCommand.addTarget(handler: { (event) in
        videoController.player?.rate == 1 ? videoController.player?.pause() : videoController.player?.play()
        return MPRemoteCommandHandlerStatus.success}
    )
    
    func skipForward() {
        guard
            let player = videoController.player
        else {
            return
        }
        
        var playerCurrentTime = CMTimeGetSeconds( player.currentTime() )
        playerCurrentTime += seekDuration
        
        let time: CMTime = CMTimeMake(value: Int64(playerCurrentTime * 1000 as Float64), timescale: 1000)
        videoController.player?.seek(to: time)
    }
    
    func skipBackward() {
        guard
            let player = videoController.player
        else {
            return
        }
        
        var playerCurrentTime = CMTimeGetSeconds( player.currentTime() )
        playerCurrentTime -= seekDuration
        
        let time: CMTime = CMTimeMake(value: Int64(playerCurrentTime * 1000 as Float64), timescale: 1000)
        videoController.player?.seek(to: time)
    }
}
