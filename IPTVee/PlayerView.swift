import SwiftUI
import iptvKit
import UIKit
import AVFAudio

struct PlayerView: View {
    internal init(url: URL?, channelName: String, streamID: String, imageUrl: String) {
        
        guard let url = url else {
            self.url = URL(string:"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8") ?? URL(fileURLWithPath: "IPTVee")
            self.channelName = channelName
            self.streamID = streamID
            self.imageUrl = imageUrl
            return
        }
        
        self.url = url
        self.channelName = channelName
        self.streamID = streamID
        self.imageUrl = imageUrl
    }

    @ObservedObject var plo = iptvKit.PlayerObservable.plo
    @ObservedObject var lgn = iptvKit.LoginObservable.shared

    @Environment(\.presentationMode) var presentationMode
    
    let uin = UINavigationItem.self
    
    let url: URL
    let channelName: String
    let streamID: String
    let imageUrl: String
    
    var played: Bool = false
    
    var isPortrait: Bool {
        guard let scene =  (UIApplication.shared.connectedScenes.first as? UIWindowScene) else {
            return true
        }
        
        return scene.interfaceOrientation.isPortrait
    }
    
    var body: some View {
        
        Group {
            GeometryReader { geometry in
                Form{}
                VStack {
                    Text("")
                        .frame(height:10)
                        .padding(0)
                    HStack {
                        AVPlayerView(url: url)
                            .frame(width: geometry.size.width, height: (geometry.size.width * 0.5625), alignment: .center)
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
        
        #if !targetEnvironment(macCatalyst)
            .refreshable {
                getShortEpg(streamId: streamID, channelName: channelName, imageURL: imageUrl)
            }
        #endif
   
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


extension Date {
    func userTimeZone( initTimeZone: TimeZone = TimeZone(identifier: iptvKit.LoginObservable.shared.config?.serverInfo.timezone ?? "America/New_York") ?? TimeZone(abbreviation: "EST") ?? .autoupdatingCurrent , timeZone: TimeZone = .autoupdatingCurrent) -> Date {
         let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
         return addingTimeInterval(delta)
    }
}
