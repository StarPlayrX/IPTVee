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
    @Published var isPlayingURL = ""
    
}

struct PlayerView: View {
    internal init(streamId: String, channelName: String) {
        self.streamId = streamId
        self.channelName = channelName
    }
    
    let streamId: String
    let channelName: String
    @State var playPauseLabel = "Toggle"
    
    @ObservedObject var plo = PlayerObservable.plo
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    func backgroundPlaybackSeam() {
        AVPVC.player?.playImmediately(atRate: 0.9)
        AVPVC.player?.play()
    }
    
    var body: some View {
        let playerView = AVPlayerView(streamID: streamId)
        GeometryReader { geometry in
            
            Group {
                playerView
                    .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
                
                    //MARK: - This is 16:9 aspect ratio
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.width * 0.5625, alignment: .topLeading)
                
                    //MARK: - Basically allowing background playback & maintaining playback / pause on lock screen
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        DispatchQueue.background(delay: 1.75, background: {
                            AVPVC.player = AVPlayer()
                            backgroundPlaybackSeam()
                        }, completion: {
                            AVPVC.player = player
                            backgroundPlaybackSeam()
                        })
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        AVPVC.player = AVPVC.player != player ? player : AVPVC.player
                        backgroundPlaybackSeam()
                    }
            }
            
        }
        .navigationTitle(channelName)
        .navigationBarItems(trailing: Button(playPauseLabel) {
            playPauseLabel = AVPVC.player?.rate == 0.0 ? "Pause" : "Play"
            AVPVC.player?.rate == 0.0 ? AVPVC.player?.play() : AVPVC.player?.pause()
        })
        
        VStack {
            Spacer()
        }.onAppear(perform: {
            AppDelegate.orientationLock = [.all]
            
        })
        .onDisappear(perform: {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        })
        
        Spacer()
    }
}
