import SwiftUI
import iptvKit
import UIKit
import AVKit

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
    
    let url: URL
    let channelName: String
    let streamID: String
    let imageUrl: String
    
    var isPortrait: Bool {
        guard let scene =  (UIApplication.shared.connectedScenes.first as? UIWindowScene) else {
            return true
        }
        
        return scene.interfaceOrientation.isPortrait
    }
    
    var body: some View {
        Text("")
            .frame(height:10)
            .padding(0)

        Group {
            GeometryReader { geometry in
                Form{}
                VStack {
                  
                    HStack {
                        AVPlayerView(url: url)
                            .frame(width: isPortrait ? geometry.size.width : .infinity, height: isPortrait ? geometry.size.width * 0.5625 : .infinity, alignment: .center)
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
                        
                        HStack {
                            
                            Button(action: {
                                skipBackward(plo.videoController)
                            }) {
                                Image(systemName: "gobackward.10")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                
                            }.frame(width: 40, height: 40)
                                .padding(5)
                                .padding(.trailing, 5)
                                .padding(.bottom, 10)
                            
                            
                            Button(action: {
                                skipForward(plo.videoController)
                            }) {
                                Image(systemName: "goforward.10")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                
                            }.frame(width: 40, height: 40)
                                .padding(5)
                                .padding(.leading, 5)
                                .padding(.bottom, 10)
                        }.frame(alignment:.bottom)
                        // This only works on each view
                            .onReceive( (PlayerObservable.plo.videoController.player!).publisher(for: \.timeControlStatus)) { newStatus in
                                switch newStatus {
                                case .waitingToPlayAtSpecifiedRate:
                                    print("waiting")
                                case .paused:
                                    print("paused")
                                case .playing:
                                    print("playing")
                                @unknown default:
                                    ()
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
    
}


extension Date {
    func userTimeZone( initTimeZone: TimeZone = TimeZone(identifier: iptvKit.LoginObservable.shared.config?.serverInfo.timezone ?? "America/New_York") ?? TimeZone(abbreviation: "EST") ?? .autoupdatingCurrent , timeZone: TimeZone = .autoupdatingCurrent) -> Date {
        let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
}
