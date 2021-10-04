//
//  AVPlayerView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/3/21.
//

import AVKit
import SwiftUI

struct AVPlayerView: UIViewControllerRepresentable {
    var streamID: String
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        AVPVC.requiresLinearPlayback = false
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        //MARK: Todo - Build this dynamically from the user's data and/or configuration using URL Components()
        player.replaceCurrentItem(with: AVPlayerItem(url: URL(string:"http://primestreams.tv:826/live/toddbruss90/zzeH7C0xdw/\(streamID).m3u8")!))
        player.play()
        
        let pvc = AVPlayerViewController()
        
        pvc.player = player
        pvc.player?.preventsDisplaySleepDuringVideoPlayback = true
        pvc.player?.allowsExternalPlayback = true
        pvc.player?.automaticallyWaitsToMinimizeStalling = true
        pvc.player?.externalPlaybackVideoGravity = .resizeAspectFill
        pvc.player?.actionAtItemEnd = .pause
        pvc.entersFullScreenWhenPlaybackBegins = true
        pvc.exitsFullScreenWhenPlaybackEnds = true
        pvc.allowsPictureInPicturePlayback = true
        pvc.canStartPictureInPictureAutomaticallyFromInline = true
        pvc.requiresLinearPlayback = true
        pvc.updatesNowPlayingInfoCenter = true
        pvc.showsTimecodes = true
        pvc.updatesNowPlayingInfoCenter = true
        pvc.requiresLinearPlayback = false
        
        if #available(iOS 15.0, *) {
            pvc.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        
        AVPVC = pvc
        return AVPVC
    }
}


