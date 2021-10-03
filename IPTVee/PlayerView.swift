//
// From SwiftUI by Example by Paul Hudson
// https://www.hackingwithswift.com/quick-start/swiftui
//
// You're welcome to use this code for any purpose,
// commercial or otherwise, with or without attribution.
//

import AVKit
import SwiftUI
import WebKit
import MediaPlayer

class PlayerObservable: ObservableObject {
    static var plo = PlayerObservable()
    @Published var loadingMsg = "Loading..."
    @Published var isLoading = true
    @Published var isPlayingURL = "http://primestreams.tv:826/live/toddbruss90/zzeH7C0xdw/36593.m3u8"

}


struct PlayerView: View {
    internal init(url: String) {
        self.url = url
    }
    
    let player = AVPlayer()
    let url: String
    
    
    func getPlayer() -> AVPlayer {
        let player = AVPlayer(url: URL(string: url)!)
        player.play()
        return player
    }
    @ObservedObject var plo = PlayerObservable.plo
    
    var body: some View {
        
        GeometryReader { geometry in
                
                AVPlayerView(videoURL: URL(string: url)).edgesIgnoringSafeArea([.bottom,.leading,.trailing])
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.width * 0.5625, alignment: .topLeading)
                
               
        }
        
        

        VStack {
            

            Spacer()
                
        }.onAppear(perform: {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
        })
        
        Spacer()
    }
}


var player = AVPlayer()

var AVPVC = AVPlayerViewController()

struct AVPlayerView: UIViewControllerRepresentable {
    
    var videoURL: URL?

    func updateUIViewController(_ pvc: AVPlayerViewController, context: Context) {
        pvc.entersFullScreenWhenPlaybackBegins = true
        pvc.allowsPictureInPicturePlayback = true
        pvc.canStartPictureInPictureAutomaticallyFromInline = true
        pvc.requiresLinearPlayback = false
        pvc.exitsFullScreenWhenPlaybackEnds = false
        pvc.showsPlaybackControls = true
        pvc.showsTimecodes = true
        pvc.updatesNowPlayingInfoCenter = true
        player = AVPlayer(url: videoURL!)
        pvc.player = player
        if #available(iOS 15.0, *) {
            pvc.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
  
        pvc.player?.automaticallyWaitsToMinimizeStalling = true

    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        AVPVC = AVPlayerViewController()
        return AVPVC
    }
}
