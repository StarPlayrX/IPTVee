import SwiftUI
import AVKit
import iptvKit
import MediaPlayer

class PlayerObservable: ObservableObject {
    static var plo = PlayerObservable()
    @Published var miniEpg: [EpgListing] = []
    @Published var videoController = AVPlayerViewController()
    @Published var player = AVPlayer()
    @Published var pip: Bool = false
    @Published var fullscreen: Bool = false
    @Published var streamID: String = ""
    @Published var channelName: String = ""
    @Published var imageURL: String = ""
}


struct PlayerView: View {
    internal init(url: URL, channelName: String, streamID: String, imageUrl: String) {
        self.url = url
        self.channelName = channelName
        self.streamID = streamID
        self.imageUrl = imageUrl
        
    }
    
    @ObservedObject var plo = PlayerObservable.plo
    
    let url: URL
    let channelName: String
    let streamID: String
    let imageUrl: String
    

    var isPortrait: Bool {
        (UIApplication.shared.connectedScenes.first as! UIWindowScene).interfaceOrientation.isPortrait
    }
    
    var body: some View {
        Group {
            
            GeometryReader { geometry in
                VStack {
                    
                    if isPortrait {
                        Text("IPTVee")
                            .fontWeight(.bold)
                    }
                    
                    PlayerView.IPTVeePlayer.AVPlayerView(url: url)
                        .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.width * 0.5625)
                        .offset(y:10)
                    
                    if isPortrait {
                        Form {
                            if !plo.miniEpg.isEmpty {
                                
                                Section(header: Text("PROGRAM GUIDE")) {
                                    ForEach(Array(plo.miniEpg),id: \.id) { epg in
                                        
                                        HStack {
                                            Text(epg.start.toDate()?.toString() ?? "")
                                                .fontWeight(.medium)
                                                .frame(minWidth: 78, alignment: .trailing)
                                                .multilineTextAlignment(.leading)
                                            
                                            Text(epg.title.base64Decoded ?? "")
                                                .multilineTextAlignment(.leading)
                                                .padding(.leading, 5)
                                        }
                                        .font(.callout)
                                    }
                                }
                            }
                            
                            if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3 {
                                Section(header: Text("Description")) {
                                    Text(desc)
                                        .font(.body)
                                        .fontWeight(.light)
                                        .frame(minWidth: 80, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                }
                            } else {
                                Section(header: Text("Description")) {
                                    Text(channelName)
                                        .font(.body)
                                        .fontWeight(.light)
                                        .frame(minWidth: 80, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                        
                        
                        HStack {
                            /* Button { skipBackward(plo.videoController)
                             } label: {
                             Image(systemName: "gobackward.10")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 35, height: 35)
                             }
                             
                             Button { skipForward(plo.videoController)
                             } label: {
                             Image(systemName: "goforward.10")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 35, height: 35)
                             }*/
                        }
                        .navigationTitle(channelName)

                        .frame(alignment: .bottom)
                    }

                }
            }
        }
        .onAppear {
            plo.streamID = streamID
            plo.channelName = channelName
            plo.imageURL = imageUrl
            getShortEpg(streamId: streamID, channelName: channelName, imageURL: imageUrl)
            plo.videoController.player?.playImmediately(atRate: 1.0)

        }
    

       /* .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
        // Save Config
            plo.videoController.showsTimecodes = true
            plo.videoController.showsPlaybackControls = true
            plo.videoController.requiresLinearPlayback = false
        }
        
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
        // Load Config
            plo.videoController.showsTimecodes = true
            plo.videoController.showsPlaybackControls = true
            plo.videoController.requiresLinearPlayback = false
        }*/
    }
}



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
    
    class IPTVeePlayer {
        
        struct AVPlayerView: UIViewControllerRepresentable {
            
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
            
            let url: URL
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
                
                commandCenter(plo.videoController)
                
                let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true]
                let asset = AVURLAsset.init(url: url, options:options)
                let avp = AVPlayerItem.init(asset: asset)
                
                plo.videoController.player?.replaceCurrentItem(with: avp)

                plo.videoController.delegate = context.coordinator
                
                return plo.videoController
            }
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



/*
 
 
 GeometryReader { geometry in
 VStack {
 VStack {
 if portrait {
 Text(" ")
 }
 }
 
 playerView
 .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
 //MARK: - This is 16:9 aspect ratio
 .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.width * 0.5625)
 if portrait {
 VStack {
 Form {
 if !plo.miniEpg.isEmpty {
 
 Section(header: Text("PROGRAM GUIDE")) {
 ForEach(Array(plo.miniEpg),id: \.id) { epg in
 
 HStack {
 Text(epg.start.toDate()?.toString() ?? "")
 .fontWeight(.medium)
 .frame(minWidth: 78, alignment: .trailing)
 .multilineTextAlignment(.leading)
 
 Text(epg.title.base64Decoded ?? "")
 .multilineTextAlignment(.leading)
 .padding(.leading, 5)
 }
 .font(.callout)
 }
 }
 
 if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3 {
 Section(header: Text("Description")) {
 Text(desc)
 .font(.body)
 .fontWeight(.light)
 .frame(minWidth: 80, alignment: .leading)
 .multilineTextAlignment(.leading)
 }
 } else {
 Section(header: Text("Description")) {
 Text(channelName)
 .font(.body)
 .fontWeight(.light)
 .frame(minWidth: 80, alignment: .leading)
 .multilineTextAlignment(.leading)
 }
 }
 
 }
 }
 .onReceive(timer) { _ in
 Calendar.current.component(.minute, from: Date()) % 6 == 0 ?
 getShortEpg(streamId: streamId, channelName: channelName, imageURL: imageUrl) : ()
 }
 }
 }
 
 
 
 HStack {
 Text("HELLO")
 Text("HELLO")
 
 }         .frame(maxWidth: geometry.size.width, maxHeight: 30, alignment: .center)
 .padding(.bottom, 30)
 
 }
 
 
 }.onAppear {
 //plo.videoController.player?.play()
 getShortEpg(streamId: streamId, channelName: channelName, imageURL: imageUrl)
 }
 
 
 
 //MARK: - Basically allowing background playback & maintaining playback / pause on lock screen
 .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
 // Save Config
 }
 .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
 // Load Config
 }
 .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
 // If our full screen viewer is in portrait or landscape, update the UI underneath
 if portrait {
 AppDelegate.interfaceMask = UIInterfaceOrientationMask.portrait
 } else {
 AppDelegate.interfaceMask = UIInterfaceOrientationMask.landscape
 }
 }
 .navigationTitle(channelName)
 .onAppear {
 AppDelegate.interfaceMask = UIInterfaceOrientationMask.all
 }
 .onDisappear {
 plo.fullScreenTriggered = true
 }
 .toolbar {
 ToolbarItemGroup(placement: .navigationBarTrailing) {
 if !portrait {
 Text(plo.miniEpg.first?.title.base64Decoded ?? "")
 .font(.footnote)
 .frame(minWidth: 160)
 .multilineTextAlignment(.trailing)
 } else {
 Button {
 shouldEnterFullScreen(ride: true)
 //shouldEnterFullScreen(plo.videoController, ride: true)
 //plo.videoController.player?.play()
 } label: {
 Image(systemName: "arrow.up.right.video")
 .resizable()
 .scaledToFit()
 .frame(width: 35, height: 35)
 }
 }
 }
 }
 }
 
 
 */


//gobackward.10
//goforward.10
