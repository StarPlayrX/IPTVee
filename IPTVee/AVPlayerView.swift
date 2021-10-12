//
//  AVPlayerView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/3/21.
//

import AVKit
import SwiftUI
import MediaPlayer
import AVFoundation

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
        
        //@State allows updating the variable in SwiftUI
        @State var playedOnce: Bool = false
        
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
            
            if playedOnce { return AVPlayerViewController() }
            
            playedOnce = true
            
            commandCenter(plo.videoController)
            
            
            
            let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true, AVURLAssetAllowsCellularAccessKey : true, AVURLAssetAllowsExpensiveNetworkAccessKey : true, AVURLAssetAllowsConstrainedNetworkAccessKey : true ]
            let asset = AVURLAsset.init(url: url, options:options)
            
          /*  let configuration = URLSessionConfiguration.background(withIdentifier: "download")
            
            
            configuration.allowsCellularAccess = true
            configuration.requestCachePolicy = .returnCacheDataDontLoad
            configuration.urlCache = .shared
               // Create a new AVAssetDownloadURLSession with background configuration, delegate, and queue
            let downloadSession = AVAssetDownloadURLSession(configuration: configuration,
                                                           assetDownloadDelegate: nil,
                                                            delegateQueue: OperationQueue.current)*/
            
            
            // Create new AVAssetDownloadTask for the desired asset
            // Passing a nil options value indicates the highest available bitrate should be downloaded
            //guard let downloadTask = downloadSession.makeAssetDownloadTask(asset: asset, assetTitle: "download", assetArtworkData: nil, options: nil) else { return plo.videoController }
            let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            //player = AVPlayer(playerItem: playerItem)
            //player.play()
            //let avp = AVPlayerItem.init(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
            //plo.videoController.player = AVPlayer(playerItem: playerItem)
            plo.videoController.player?.replaceCurrentItem(with: playerItem)
            plo.videoController.player?.currentItem?.seekingWaitsForVideoCompositionRendering = false
            //plo.videoController.player?.currentItem?.videoApertureMode = .cleanAperture
            plo.videoController.player?.currentItem?.appliesPerFrameHDRDisplayMetadata = true
             plo.videoController.player?.currentItem?.preferredForwardBufferDuration = 0
            plo.videoController.player?.currentItem?.automaticallyPreservesTimeOffsetFromLive = true
            plo.videoController.player?.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            
            plo.videoController.player?.play()
            plo.videoController.player?.currentItem?.configuredTimeOffsetFromLive = .init(seconds: 34, preferredTimescale: 1000)
            plo.videoController.player?.currentItem?.startsOnFirstEligibleVariant = true
            plo.videoController.player?.currentItem?.variantPreferences = .scalabilityToLosslessAudio
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


func downloadAndPlayAsset(_ asset: AVURLAsset) {
    
}

