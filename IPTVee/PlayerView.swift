import SwiftUI
import AVKit
import iptvKit

struct PlayerView: View {
    @State private var showDetails = false
    @State private var orientation = UIDeviceOrientation.unknown
    
    @ObservedObject var plo = PlayerObservable.plo
    @ObservedObject var pvc = PlayerViewControllerObservable.pvc
    
    @State var streamID: Int = 0
    @State var name: String = ""
    @State var streamIcon: String = ""
    @State var categoryName: String = ""
    @State var videoStarted: Bool = false
    let epgChannelId: String?
    
    var isPortraitFallback: Bool {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return true
        }
        return scene.interfaceOrientation.isPortrait
    }
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    
    var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    func refresher() {
        DispatchQueue.global(qos: .background).async {
            antiTimeBubblePopper()
        }
    }
    
    @State var isPortrait: Bool = false
    
    var body: some View {
        
        Group {
            
            GeometryReader { geometry in
                Text("")
                Form{}
                VStack {
                    let avPlayerView = AVPlayerView(streamID: streamID, name: name, streamIcon: streamIcon)
                    
                    if isPad || (isPhone && isPortrait) {
                        avPlayerView
                            .frame(width: geometry.size.width, height: geometry.size.width * 0.5625, alignment: .top)
                            .navigationBarHidden(false)
                    } else {
                        avPlayerView
                            .ignoresSafeArea(.all)
                            .edgesIgnoringSafeArea(.all)
                            .navigationBarHidden(true)
                    }
                    
                    if isPortrait || isPad {
                        NowPlayingView( epgChannelId: epgChannelId, categoryName: categoryName)
                            .refreshable {
                                refresher()
                            }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(name)
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    isPortrait = updatePortrait()
                }
                .onAppear {
                    isPortrait = updatePortrait()
                    plo.channelName = name
                }
            }
        }
    }
    
    func performMagicTap() {
        pvc.videoController.player?.rate == 1 ? pvc.videoController.player?.pause() : pvc.videoController.player?.play()
    }

    //Back burner
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
    
    //Back burner
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
}
