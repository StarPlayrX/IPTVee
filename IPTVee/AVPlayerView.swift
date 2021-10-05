//
//  AVPlayerView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/3/21.
//

import AVKit
import SwiftUI

struct AVPlayerView: UIViewControllerRepresentable {
    
    let streamID: String
    
    func updateUIViewController(_ playerViewController: AVPlayerViewController, context: Context) {
      
      //  enterFullscreen(playerViewController)

    }


    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
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
        pvc.showsPlaybackControls = true
        pvc.updatesNowPlayingInfoCenter = true
        pvc.requiresLinearPlayback = false
        if #available(iOS 15.0, *) {
            pvc.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        
        AVPVC = pvc
        
        enterFullscreen(AVPVC)

        
        return AVPVC
    }
}


private func enterFullscreen(_ playerViewController: AVPlayerViewController) {

    if playerViewController.entersFullScreenWhenPlaybackBegins {
        AVPVC.entersFullScreenWhenPlaybackBegins = false
        
        let selectorName: String = {
            return "_transitionToFullScreenAnimated:interactive:completionHandler:"

        }()
        let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)

        if playerViewController.responds(to: selectorToForceFullScreenMode) {
            playerViewController.perform(selectorToForceFullScreenMode, with: true, with: nil)
        }
    }
}
