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
    @Published var fullScreenTriggered: Bool = false
    @Published var disableVideoController: Bool = false
    @Published var isOkayToPlay: Bool = false

}

struct PlayerView: View {
    internal init(streamId: String, channelName: String) {
        self.streamId = streamId
        self.channelName = channelName
    }
    
    let streamId: String
    let channelName: String

    //@State var playPauseLabel = "Toggle"
    @ObservedObject var plo = PlayerObservable.plo
    
    var body: some View {

        Spacer()

        HStack {
            GeometryReader { geometry in
                
                HStack {
                    

                    AVPlayerView(streamID: streamId)
                        .onTapGesture {
                            AVPVC.showsPlaybackControls = false
                            
                            if player.rate == 1 {
                                enterFullscreen(AVPVC)
                            } else {
                                AVPVC.player?.rate == 0 ? AVPVC.player?.play() : AVPVC.player?.pause()
                                plo.isOkayToPlay = AVPVC.player?.rate == 0 ? false : true

                            }
                        }
                        .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
                    
                    //MARK: - This is 16:9 aspect ratio
                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.width * 0.5625, alignment: .topLeading)
                    
                    //MARK: - Basically allowing background playback & maintaining playback / pause on lock screen
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                            
                            // Creates a seamless background audio user experience
                            DispatchQueue.background(delay: 1.0, background: {
                                AVPVC.player = nil
                            }, completion: {
                                AVPVC.player = player
                            })
                        }
                    
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                            
                            // Ensures our player is reattached to the VC
                            AVPVC.player = AVPVC.player != player ? player : AVPVC.player
                        }
                        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                            
                            //Ensures we will not run our full screen startup again within the same session
                            plo.fullScreenTriggered = true
                            
                            // If our full screen viewer is in portrait or landscape, update the UI underneath
                            if UIDevice.current.orientation.isPortrait {
                                AppDelegate.interfaceMask = UIInterfaceOrientationMask.portrait
                            } else if UIDevice.current.orientation.isLandscape {
                                AppDelegate.interfaceMask = UIInterfaceOrientationMask.landscape
                            }
                        }
                }
                
                Spacer()
                
            }
            .navigationTitle(channelName)
            //MARK: Put the favorites button here instead
            /*.navigationBarItems(trailing: Button(playPauseLabel) {
             playPauseLabel = AVPVC.player?.rate == 0.0 ? "Pause" : "Play"
             AVPVC.player?.rate == 0.0 ? AVPVC.player?.play() : AVPVC.player?.pause()
             })*/
            
           
        }
        .onAppear {
            AVPVC.showsPlaybackControls = false
            AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
        }
        .onDisappear {
            AVPVC.showsPlaybackControls = true
            AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
        }
    }
}
