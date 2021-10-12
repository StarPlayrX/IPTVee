import SwiftUI
import AVKit
import iptvKit
import MediaPlayer

class PlayerObservable: ObservableObject {
    static var plo = PlayerObservable()
    @Published var miniEpg: [EpgListing] = []
    @Published var videoController = AVPlayerViewController()
    @Published var pip: Bool = false
    @Published var fullscreen: Bool = false
    @Published var reset: Bool = false
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
    
    var played: Bool = false
  
    var isPortrait: Bool {
        (UIApplication.shared.connectedScenes.first as! UIWindowScene).interfaceOrientation.isPortrait
    }
    
    var body: some View {
        Group {
            
            GeometryReader { geometry in
                VStack {
                    
                    if isPortrait {
                        //IPTVee Logo
                        HStack {
                            Text("IPTV")
                                .fontWeight(.bold)
                                .frame(alignment: .trailing)
                                .offset(x: 4.3)

                            Text("ee")
                                .fontWeight(.light)
                                .frame(alignment: .leading)
                                .offset(x: -4.3)
                        }
                        .foregroundColor( Color(.displayP3, red: 63 / 255, green: 188 / 255, blue: 237 / 255)  )
                    }
                    
                    AVPlayerView(url: url)
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
            
            /*DispatchQueue.background(delay: 0.0) {
                plo.videoController.player?.rate = 0.0
                while ( plo.videoController.player?.status != .readyToPlay ) {}
            } completion: {
                if plo.videoController.player?.status == .readyToPlay {
                    plo.videoController.player?.preroll(atRate: 2.0, completionHandler: { Bool in
                        if Bool {
                            plo.videoController.player?.playImmediately(atRate: 1.0)
                        }
                    })
                }
            }*/
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
