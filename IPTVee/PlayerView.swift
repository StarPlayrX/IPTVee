import SwiftUI
import iptvKit

class PlayerObservable: ObservableObject {
    static var plo = PlayerObservable()
    @Published var loadingMsg = "Loading..."
    @Published var isLoading = true
    @Published var isPlayingURL = ""
    @Published var fullScreenTriggered: Bool = false
    @Published var disableVideoController: Bool = false
    @Published var isOkayToPlay: Bool = true
    @Published var miniEpg: [EpgListing] = []
}

struct PlayerView: View {
    internal init(channelName: String, streamId: String, imageUrl: String) {
        self.channelName = channelName
        self.streamId = streamId
        self.imageUrl = imageUrl
    }
    
    let channelName: String
    let streamId: String
    let imageUrl: String
    let timer = Timer.publish(every: 100, on: .main, in: .common).autoconnect()
    @ObservedObject var plo = PlayerObservable.plo
    
    var portrait: Bool {
        (UIApplication.shared.connectedScenes.first as! UIWindowScene).interfaceOrientation.isPortrait
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    if portrait {
                        Text(" ")
                    }
                }
                
                AVPlayerView(streamId: streamId)
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
            plo.isOkayToPlay = true
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
                        shouldEnterFullScreen(videoController, ride: true)
                        videoController.player?.play()
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
}
