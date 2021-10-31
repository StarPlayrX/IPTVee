
import AVKit
import SwiftUI
import MediaPlayer
import iptvKit

public var avSession = AVAudioSession.sharedInstance()

public struct AVPlayerView: UIViewControllerRepresentable {
    
    @ObservedObject var plo = PlayerObservable.plo
    @ObservedObject var lo = LoginObservable.shared

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
    
    public func updateUIViewController(_ videoController: AVPlayerViewController, context: Context) {
        
        
    }
    
    public func makeUIViewController(context: Context) -> AVPlayerViewController {
        runAVSession()
        
        plo.videoController.showsPlaybackControls = true
        plo.videoController.delegate = context.coordinator
           plo.videoController.requiresLinearPlayback = false
          plo.videoController.canStartPictureInPictureAutomaticallyFromInline = true
        //    plo.videoController.accessibilityPerformMagicTap()
        
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
        plo.videoController.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        plo.videoController.player?.currentItem?.configuredTimeOffsetFromLive = .init(seconds: 60, preferredTimescale: 600)
        plo.videoController.player?.currentItem?.startsOnFirstEligibleVariant = true
        plo.videoController.player?.currentItem?.variantPreferences = .scalabilityToLosslessAudio
         
     //    if SettingsObservable.shared. {
       //      plo.videoController.player?.pause()
         //}
         
        plo.videoController.player?.automaticallyWaitsToMinimizeStalling = true
        plo.videoController.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        
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