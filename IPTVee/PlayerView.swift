import SwiftUI
import AVKit
import iptvKit



struct PlayerView: View {
    @State private var showDetails = false
    
    @ObservedObject var plo = PlayerObservable.plo
    
    var isPortrait: Bool {
        guard let scene =  (UIApplication.shared.connectedScenes.first as? UIWindowScene) else {
            return true
        }
        
        if orientation.isPortrait {
            return true
        }
        
        return scene.interfaceOrientation.isPortrait
    }
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    @State var orientation = UIDevice.current.orientation
    
    @State var avPlayerView = AVPlayerView()
    
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack {
                
                HStack {
                    
                    if isPad {
                        avPlayerView
                        
                        
                            .frame(width: geometry.size.width, height: geometry.size.width * 0.5625, alignment: .topLeading)
                            .background(Color(UIColor.systemBackground))
                    } else {
                            
                        if isPortrait {
                            avPlayerView
                            .frame(width: geometry.size.width, height: geometry.size.width * 0.5625, alignment: .topLeading)
                            .background(Color(UIColor.systemBackground))
                        } else {
                            avPlayerView
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)
                                                     .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .topLeading)

                                .background(Color(UIColor.systemBackground))
                        }
                        
                    }
                        
                    }



                
                if isPortrait {
                    
                    List {
                        if !plo.miniEpg.isEmpty {
                            
                            Section(header: Text("PROGRAM GUIDE").frame(height:20).foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold))) {
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
                        }
                        
                        if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3 {
                                Section(header: Text("Description").frame(height:20).foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold)))  {
                                Text(desc)
                                //.font(.body)
                                //.fontWeight(.light)
                                    .frame(minWidth: 80, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }
                        } else {
                            Section(header: Text("Description").frame(height:20).foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold))) {
                                Text(plo.channelName)
                                    .font(.body)
                                    .fontWeight(.light)
                                    .frame(minWidth: 80, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }
                            
                        }
                    }
                    .animation(.easeIn(duration: 0.3))
                    .transition(.opacity)
                    
#if targetEnvironment(macCatalyst)
                    .refreshable {
                        getShortEpg(streamId: plo.streamID, channelName: plo.channelName, imageURL: plo.imageURL)
                    }
#endif
                    
                    
                } else if !plo.miniEpg.isEmpty && isPad  {
                    
                    List {
                        Section(header: Text("PROGRAM GUIDE").frame(height:20).foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold)))  {
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(plo.channelName)
            .onReceive(orientationChanged) { _ in
                self.orientation = UIDevice.current.orientation
                print(orientation.isPortrait)
            }
            
            .onAppear{
                
            }
        }
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
