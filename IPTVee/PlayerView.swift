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
    let timer = Timer.publish(every: 100, on: .main, in: .common).autoconnect()
    
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
                            getShortEpg(streamId: streamId) : ()
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
