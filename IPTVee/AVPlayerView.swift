
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
        if plo.streamID != plo.previousStreamID {
            plo.previousStreamID = plo.streamID
            plo.videoController = setupPlayerToPlay()
            plo.videoController = setupVideoController()
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

public func setupVideoController() -> AVPlayerViewController{
    let plo = PlayerObservable.plo
    plo.videoController.showsTimecodes = true
    plo.videoController.entersFullScreenWhenPlaybackBegins = false
    plo.videoController.updatesNowPlayingInfoCenter = false
    plo.videoController.showsPlaybackControls = true
    plo.videoController.requiresLinearPlayback = false
    plo.videoController.canStartPictureInPictureAutomaticallyFromInline = true
    plo.videoController.videoGravity = .resizeAspect
    plo.videoController.accessibilityPerformMagicTap()
    return plo.videoController
}

public func setupPlayerToPlay() -> AVPlayerViewController {
    
    let plo = PlayerObservable.plo
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
    plo.videoController.player?.currentItem?.preferredForwardBufferDuration = 60
    plo.videoController.player?.currentItem?.automaticallyPreservesTimeOffsetFromLive = true
    plo.videoController.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
    plo.videoController.player?.currentItem?.configuredTimeOffsetFromLive = .init(seconds: 60, preferredTimescale: 600)
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
