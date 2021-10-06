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
    internal init(channelName: String, playerView: AVPlayerView) {
        self.channelName = channelName
        self.playerView = playerView
    }
    
    let channelName: String
    let playerView: AVPlayerView
    @ObservedObject var plo = PlayerObservable.plo
    
    var body: some View {
        
        
        GeometryReader { geometry in
            
            Group {
                
                playerView
                    .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
                
                //MARK: - This is 16:9 aspect ratio
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.width * 0.5625)
                    .offset(y: UIApplication.shared.statusBarOrientation.isPortrait  ? 30 : 0)
                //MARK: - Basically allowing background playback & maintaining playback / pause on lock screen
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        // Save Config
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                        // Load Config
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                        // If our full screen viewer is in portrait or landscape, update the UI underneath
                        if UIApplication.shared.statusBarOrientation.isPortrait {
                            AppDelegate.interfaceMask = UIInterfaceOrientationMask.portrait
                        } else if UIApplication.shared.statusBarOrientation.isLandscape {
                            AppDelegate.interfaceMask = UIInterfaceOrientationMask.landscape
                        }
                    }
            }
            .navigationTitle(channelName)
            .onAppear {
                AppDelegate.interfaceMask = UIInterfaceOrientationMask.all
            }
            .onDisappear {
                plo.fullScreenTriggered = true
            }
        }
    }
}
