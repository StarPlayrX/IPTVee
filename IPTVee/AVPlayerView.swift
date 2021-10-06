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
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
       // if plo.disableVideoController { return }
    print("UPDATE")
        if !plo.fullScreenTriggered {
            plo.fullScreenTriggered = true
            enterFullscreen(AVPVC)
        }
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
       // if plo.disableVideoController { return AVPlayerViewController() }
        print("NO UPDATE")

        guard let conf = LoginObservable.shared.config else { return AVPlayerViewController() }
        
        let user = conf.userInfo.username
        let pass = conf.userInfo.password
        let url = conf.serverInfo.url
        let port = conf.serverInfo.port
 
        //MARK: Todo - Build this dynamically using URL Components()
        guard let url = URL(string:"http://\(url):\(port)/live/\(user)/\(pass)/\(streamID).m3u8") else { return AVPlayerViewController() }
                
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.playImmediately(atRate: 1.0)
        player.preventsDisplaySleepDuringVideoPlayback = true
        player.allowsExternalPlayback = true
        player.externalPlaybackVideoGravity = .resizeAspectFill
        player.actionAtItemEnd = .pause
        player.automaticallyWaitsToMinimizeStalling = true
        
        let pvc = AVPlayerViewController()
     
        pvc.player = player
        pvc.entersFullScreenWhenPlaybackBegins = true
        pvc.exitsFullScreenWhenPlaybackEnds = false
        pvc.allowsPictureInPicturePlayback = true
        pvc.canStartPictureInPictureAutomaticallyFromInline = false
        pvc.updatesNowPlayingInfoCenter = true
        pvc.showsTimecodes = true
        pvc.showsPlaybackControls = false
        pvc.updatesNowPlayingInfoCenter = true
        pvc.requiresLinearPlayback = false
        if #available(iOS 15.0, *) {
            pvc.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        
        AVPVC = pvc
        
        if !plo.fullScreenTriggered {
            plo.fullScreenTriggered = true
            enterFullscreen(AVPVC)
        }

        return AVPVC
    }
}


 func enterFullscreen(_ playerViewController: AVPlayerViewController) {

    if playerViewController.entersFullScreenWhenPlaybackBegins {
        
        playerViewController.showsPlaybackControls = true

        let selectorName: String = {
            return "_transitionToFullScreenAnimated:interactive:completionHandler:"

        }()
        let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)

        if playerViewController.responds(to: selectorToForceFullScreenMode) {
            playerViewController.perform(selectorToForceFullScreenMode, with: true, with: nil)
        }
    }
}
