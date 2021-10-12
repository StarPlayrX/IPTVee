//
//  AVPlayerView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/3/21.
//

import AVKit
import SwiftUI
import MediaPlayer

extension PlayerView {
    
    func skipForward(_ videoController: AVPlayerViewController ) {
        let seekDuration: Double = 10
        videoController.player?.pause()
        
        guard
            let player = videoController.player
        else {
            return
        }
        
        var playerCurrentTime = CMTimeGetSeconds( player.currentTime() )
        playerCurrentTime += seekDuration
        
        let time: CMTime = CMTimeMake(value: Int64(playerCurrentTime * 1000 as Double), timescale: 1000)
        videoController.player?.seek(to: time)
        videoController.player?.play()
    }
    
    func skipBackward(_ videoController: AVPlayerViewController ) {
        let seekDuration: Double = 10
        videoController.player?.pause()
        
        guard
            let player = videoController.player
        else {
            return
        }
        
        var playerCurrentTime = CMTimeGetSeconds( player.currentTime() )
        playerCurrentTime -= seekDuration
        
        let time: CMTime = CMTimeMake(value: Int64(playerCurrentTime * 1000 as Double), timescale: 1000)
        videoController.player?.seek(to: time)
        videoController.player?.play()
    }
    
   
    struct AVPlayerView: UIViewControllerRepresentable {
            internal init(url: URL) {
                self.url = url
                
            }
        
            let url: URL
        
            
            func commandCenter(_ videoController: AVPlayerViewController) {
                
                let commandCenter = MPRemoteCommandCenter.shared()
                
                commandCenter.accessibilityActivate()
                
                commandCenter.playCommand.addTarget(handler: { (event) in
                    videoController.player?.play()
                    return MPRemoteCommandHandlerStatus.success}
                )
                
                commandCenter.pauseCommand.addTarget(handler: { (event) in
                    videoController.player?.pause()
                    return MPRemoteCommandHandlerStatus.success}
                )
                
                commandCenter.togglePlayPauseCommand.addTarget(handler: { (event) in
                    videoController.player?.rate == 1 ? videoController.player?.pause() : videoController.player?.play()
                    return MPRemoteCommandHandlerStatus.success}
                )
            }
            
            @ObservedObject var plo = PlayerObservable.plo
            
            class Coordinator: NSObject, AVPlayerViewControllerDelegate, UINavigationControllerDelegate {
                
                let po = PlayerObservable.plo
                
                func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
                    po.fullscreen = true
                }
                
                func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
                    po.fullscreen = false
                }
                
                func playerViewControllerWillStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
                    po.pip = true
                }
                
                func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
                    po.pip = false
                }
            }
            
            func makeCoordinator() -> Coordinator {
                Coordinator()
            }
            
            func updateUIViewController(_ videoController: AVPlayerViewController, context: Context) {}
            
            func makeUIViewController(context: Context) -> AVPlayerViewController {
                commandCenter(plo.videoController)
                
                let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true]
                let asset = AVURLAsset.init(url: url, options:options)
                let avp = AVPlayerItem.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
                plo.videoController.player?.replaceCurrentItem(with: avp)
                plo.videoController.player?.currentItem?.seekingWaitsForVideoCompositionRendering = true
                plo.videoController.player?.currentItem?.videoApertureMode = .cleanAperture
                plo.videoController.player?.currentItem?.appliesPerFrameHDRDisplayMetadata = true
                plo.videoController.player?.currentItem?.preferredForwardBufferDuration = 10
                plo.videoController.player?.currentItem?.automaticallyPreservesTimeOffsetFromLive = true
                plo.videoController.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                plo.videoController.player?.currentItem?.configuredTimeOffsetFromLive = .init(seconds: 10, preferredTimescale: 600)
                plo.videoController.player?.currentItem?.startsOnFirstEligibleVariant = true

                plo.videoController.delegate = context.coordinator
                
                return plo.videoController
            }
        }
    }

extension PlayerView {
    
    func setRequiresLinearPlayback(_ videoController: AVPlayerViewController) {
        if videoController.exitsFullScreenWhenPlaybackEnds {
            let selector = NSSelectorFromString("setRequiresLinearPlayback:")
            if videoController.responds(to: selector) {
                videoController.perform(selector, with: false, with: nil)
            }
        }
    }
}
