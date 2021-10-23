import SwiftUI
import iptvKit
import UIKit
import AVFAudio

struct PlayerView: View {
    internal init(url: URL?, channelName: String, streamID: String, imageUrl: String) {
        
        self.url = url!
        self.channelName = channelName
        self.streamID = streamID
        self.imageUrl = imageUrl
    }
    
    
    @ObservedObject var plo = iptvKit.PlayerObservable.plo
    @Environment(\.presentationMode) var presentationMode
    
    let uin = UINavigationItem.self
    
    let url: URL
    let channelName: String
    let streamID: String
    let imageUrl: String
    
    var played: Bool = false
    
    var isPortrait: Bool {
        (UIApplication.shared.connectedScenes.first as! UIWindowScene).interfaceOrientation.isPortrait
    }
    
    var body: some View {
        let avPlayerView: AVPlayerView =  AVPlayerView(url: url)
        
        Group {
            GeometryReader { geometry in
                Form{}
                VStack {
                    Text("")
                        .frame(height:10)
                        .padding(0)
                    HStack {
                        avPlayerView
                            .frame(maxWidth: geometry.size.width, maxHeight: (geometry.size.width * 0.5625), alignment: .center)
                            .background(Color(UIColor.systemBackground))
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            if !isPortrait, let desc = plo.miniEpg.first?.title.base64Decoded, desc.count > 3 {
                                VStack {
                                    Text("\(channelName)")
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
                                    //.font(.body)
                                    //.fontWeight(.light)
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
                }
            }
        }
        .refreshable {
            getShortEpg(streamId: streamID, channelName: channelName, imageURL: imageUrl)
        }
        .accessibilityAction(.magicTap, {performMagicTap()})
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(channelName)
        .onAppear {
            plo.streamID = streamID
            plo.channelName = channelName
            plo.imageURL = imageUrl
            plo.videoController.updatesNowPlayingInfoCenter = false
            getShortEpg(streamId: streamID, channelName: channelName, imageURL: imageUrl)
        }
    }
    
    func performMagicTap() {
        plo.videoController.player?.rate == 1 ? plo.videoController.player?.pause() : plo.videoController.player?.play()
    }
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
