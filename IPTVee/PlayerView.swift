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
        VStack {
            AVPlayerView(videoURL: URL(string: url)).edgesIgnoringSafeArea(.all)
        }.onAppear(perform: {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.landscape
        })
    }
}


struct AVPlayerView: UIViewControllerRepresentable {

    var videoURL: URL?

    private var player: AVPlayer {
        return AVPlayer(url: videoURL!)
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {
       // playerController.modalPresentationStyle = .pageSheet
        playerController.player = player
        playerController.player?.play()
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        return AVPlayerViewController()
    }
}
