
import AVKit
import SwiftUI
import MediaPlayer
import iptvKit

public var avSession = AVAudioSession.sharedInstance()

public struct AVPlayerView: UIViewControllerRepresentable {
    
    @ObservedObject var plo = PlayerObservable.plo

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public func updateUIViewController(_ videoController: AVPlayerViewController, context: Context) {
        runAVSession()
    }
    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        guard let _ = plo.videoController.player else { return plo.videoController }

        if plo.streamID != plo.previousStreamID {
            plo.previousStreamID = plo.streamID
            plo.videoController = setupPlayerToPlay()
            plo.videoController = setupVideoController()
            setupRemoteTransportControls()
            plo.videoController.delegate = context.coordinator
            return plo.videoController
        } else {
            let player = plo.videoController.player
            plo.videoController = AVPlayerViewController()
            plo.videoController.player = player
            return plo.videoController
        }
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

public func startupAVPlayer() {
    let plo = PlayerObservable.plo
    
    plo.videoController.player = AVPlayer(playerItem: nil)
    plo.videoController.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
    plo.videoController.view.backgroundColor = UIColor.clear
}

public func setupVideoController() -> AVPlayerViewController {
    
    let plo = PlayerObservable.plo
    guard let _ = plo.videoController.player else { return plo.videoController }
    
    plo.videoController.showsTimecodes = true
    plo.videoController.entersFullScreenWhenPlaybackBegins = false
    plo.videoController.updatesNowPlayingInfoCenter = false
    plo.videoController.showsPlaybackControls = true
    plo.videoController.requiresLinearPlayback = false
    plo.videoController.canStartPictureInPictureAutomaticallyFromInline = true
    plo.videoController.videoGravity = .resizeAspect
    plo.videoController.accessibilityPerformMagicTap()
    plo.videoController.view.backgroundColor = UIColor.clear
    return plo.videoController
}

public func setupPlayerToPlay() -> AVPlayerViewController {

    let plo = PlayerObservable.plo
    guard let _ = plo.videoController.player else { return plo.videoController }

    let player = plo.videoController.player
    player?.replaceCurrentItem(with: nil)
    plo.videoController = AVPlayerViewController()
    plo.videoController.player = player
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
    plo.videoController.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
    plo.videoController.player?.currentItem?.configuredTimeOffsetFromLive = .init(seconds: 30, preferredTimescale: 1200)
    plo.videoController.player?.currentItem?.startsOnFirstEligibleVariant = true
    plo.videoController.player?.currentItem?.variantPreferences = .scalabilityToLosslessAudio
    plo.videoController.player?.automaticallyWaitsToMinimizeStalling = true
    plo.videoController.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
    return plo.videoController
}

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



func setupRemoteTransportControls() {
    let plo = PlayerObservable.plo

    guard let _ = plo.videoController.player  else { return }


    let commandCenter = MPRemoteCommandCenter.shared()
    let seekDuration: Float64 = 10
    
    commandCenter.accessibilityActivate()
    
    commandCenter.playCommand.addTarget(handler: { (event) in
        plo.videoController.player?.play()
        return MPRemoteCommandHandlerStatus.success}
    )
    
    commandCenter.pauseCommand.addTarget(handler: { (event) in
        plo.videoController.player?.pause()
        return MPRemoteCommandHandlerStatus.success}
    )
    
    commandCenter.skipBackwardCommand.addTarget(handler: { (event) in
        skipBackward()
        return MPRemoteCommandHandlerStatus.success}
    )
    
    commandCenter.skipForwardCommand.addTarget(handler: { (event) in
        skipForward()
        
        if let vcp =  plo.videoController.player, let ci = vcp.currentItem, (!ci.isPlaybackLikelyToKeepUp || ci.isPlaybackBufferEmpty) {
            skipBackward()
        }
        
        return MPRemoteCommandHandlerStatus.success}
    )
    
    commandCenter.togglePlayPauseCommand.addTarget(handler: { (event) in
        plo.videoController.player?.rate == 1 ?  plo.videoController.player?.pause() :  plo.videoController.player?.play()
        return MPRemoteCommandHandlerStatus.success}
    )
    
    func skipForward() {
        guard
            let player = plo.videoController.player
        else {
            return
        }
        
        var playerCurrentTime = CMTimeGetSeconds( player.currentTime() )
        playerCurrentTime += seekDuration
        
        let time: CMTime = CMTimeMake(value: Int64(playerCurrentTime * 1000 as Float64), timescale: 1000)
        plo.videoController.player?.seek(to: time)
    }
    
    func skipBackward() {
        guard
            let player = plo.videoController.player
        else {
            return
        }
        
        var playerCurrentTime = CMTimeGetSeconds( player.currentTime() )
        playerCurrentTime -= seekDuration
        
        let time: CMTime = CMTimeMake(value: Int64(playerCurrentTime * 1000 as Float64), timescale: 1000)
        plo.videoController.player?.seek(to: time)
    }
}
