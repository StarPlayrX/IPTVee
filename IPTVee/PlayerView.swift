import SwiftUI
import AVKit
import iptvKit

let avPlayerView = AVPlayerView()

struct NowPlayingView: View {
    @ObservedObject var plo = PlayerObservable.plo
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var isMac: Bool {
#if targetEnvironment(macCatalyst)
        true
#else
        false
#endif
    }
     
   @State var isPortrait: Bool = true
    
    var body: some View {
        List {
            if !plo.miniEpg.isEmpty && (isPortrait || isMac ) {
                
                Section(header: Text("Program Guide").foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold))) {
                    ForEach(Array(plo.miniEpg),id: \.id) { epg in
                        
                        HStack {
                            Text(epg.start.toDate()?.userTimeZone().toString() ?? "")
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
                    Section(header: Text("Description").foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold)))  {
                        Text(desc)
                            .frame(minWidth: 80, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                } else if (isPhone || isMac)  {
                    Section(header: Text("Description").foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold))) {
                        Text(plo.channelName)
                            .font(.body)
                            .fontWeight(.light)
                            .frame(minWidth: 80, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                }
                
            } else if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3 {
                
                HStack {
                    Text(plo.miniEpg.first?.start.toDate()?.userTimeZone().toString() ?? "")
                        .fontWeight(.medium)
                        .frame(minWidth: 78, alignment: .trailing)
                        .multilineTextAlignment(.leading)
                    
                    Text(plo.miniEpg.first?.title.base64Decoded ?? "")
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 5)
                }
                .font(.callout)
                
                if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3 {
                    Text(desc)
                        .frame(minWidth: 80, alignment: .leading)
                        .multilineTextAlignment(.leading)
                } else if (isPhone || isMac)  {
                    Text(plo.channelName)
                        .font(.body)
                        .fontWeight(.light)
                        .frame(minWidth: 80, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .refreshable {
            getShortEpg(streamId: plo.streamID, channelName: plo.channelName, imageURL: plo.imageURL)
        }
    }
}


struct PlayerView: View {
    @State private var showDetails = false
    @State private var orientation = UIDeviceOrientation.unknown
    
    @ObservedObject var plo = PlayerObservable.plo
    @State var isPortrait: Bool = true
    
    var isPortraitFallback: Bool {
        guard let scene =  (UIApplication.shared.connectedScenes.first as? UIWindowScene) else {
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
    
    var isMac: Bool {
    #if targetEnvironment(macCatalyst)
        true
    #else
        false
    #endif
    }
    
    fileprivate func getOrientation() {
        if UIDevice.current.orientation.isPortrait { isPortrait = true; return}
        if UIDevice.current.orientation.isLandscape { isPortrait = false; return}
        isPortrait = isPortraitFallback
    }
    

    var body: some View {
        EmptyView()
        
        Group {
            
            GeometryReader { geometry in
                Form{}
                
                VStack {
                    
                    if isPad {
                        avPlayerView
                            .frame(width: geometry.size.width, height: geometry.size.width * 0.5625, alignment: .top)
                            .transition(.opacity)

                    } else {
                        avPlayerView
                            .frame(width: isPortrait ? geometry.size.width : .infinity, height: isPortrait ? geometry.size.width * 0.5625 : .infinity, alignment: .top)
                            .transition(.opacity)
                    }
                    
                    if (isPortrait && !isPhone) || isPad {
                        Group {
                            NowPlayingView(isPortrait: isPortrait)
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.875))
                        
                    } else if isPortrait && isPhone {
                        Group {
                            NowPlayingView(isPortrait: isPortrait)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        if !isPortrait, let desc = plo.miniEpg.first?.title.base64Decoded, desc.count > 3 {
                            VStack {
                                Text("\(plo.channelName)")
                                    .fontWeight(.bold)
                                Text("\(desc)")
                                    .fontWeight(.regular)
                            }
                            .frame(alignment: .center)
                            .multilineTextAlignment(.center)
                            .frame(minWidth: 320, alignment: .center)
                            .font(.body)
                        }
                    }
                }
              

                .onAppear{getOrientation()}
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                    getOrientation()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(plo.channelName)

    }
    
    func performMagicTap() {
        plo.videoController.player?.rate == 1 ? plo.videoController.player?.pause() : plo.videoController.player?.play()
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
