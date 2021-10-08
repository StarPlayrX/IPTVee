import SwiftUI
import iptvKit

class PlayerObservable: ObservableObject {
    static var plo = PlayerObservable()
    @Published var loadingMsg = "Loading..."
    @Published var isLoading = true
    @Published var isPlayingURL = ""
    @Published var fullScreenTriggered: Bool = false
    @Published var disableVideoController: Bool = false
    @Published var isOkayToPlay: Bool = false
    @Published var miniEpg: [EpgListing] = []
    
}

struct PlayerView: View {
    internal init(channelName: String, streamId: String, playerView: AVPlayerView) {
        self.channelName = channelName
        self.streamId = streamId
        self.playerView = playerView
    }
    
    let channelName: String
    let streamId: String
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    let playerView: AVPlayerView
    
    @ObservedObject var plo = PlayerObservable.plo
    
    var portrait: Bool {
        (UIApplication.shared.connectedScenes.first as! UIWindowScene).interfaceOrientation.isPortrait
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    if portrait {
                        Text("IPTVee")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                            .frame(width: geometry.size.width, alignment: .center)
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
                                ForEach(Array(plo.miniEpg),id: \.id) { epg in
                                    
                                    HStack {
                                        Text(epg.start.toDate()?.toString() ?? "")
                                            .fontWeight(.bold)
                                            .frame(minWidth: 160)
                                        Text(epg.title.base64Decoded ?? "")
                                    }
                                    .font(.footnote)
                                    .multilineTextAlignment(.leading)
                                }
                                
                            }
                        }
                        .onReceive(timer) { _ in
                            getShortEpg(streamId: streamId)
                        }
                    }
                }
              
            }.onAppear {
                getShortEpg(streamId: streamId)
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
                
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if !portrait {
                        Text(plo.miniEpg.first?.start.toDate()?.toString() ?? "")
                            .fontWeight(.bold)
                            .frame(minWidth: 320)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !portrait {
                        Text(plo.miniEpg.first?.title.base64Decoded ?? "")
                            .font(.footnote)
                            .frame(minWidth: 320)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }
}
