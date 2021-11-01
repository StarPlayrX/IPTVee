//
//  ChannelsView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/1/21.
//

import SwiftUI
import iptvKit
import AVKit

struct ChannelsView: View {
    
    internal init(categoryID: String, categoryName: String) {
        self.categoryID = categoryID
        self.categoryName = categoryName
    }
    
    let categoryID: String
    let categoryName: String
    @State var searchText: String = ""
    @State var selectedChannel: String?
    @State var isActive: Bool = false
    @State var selectedItem: Int?
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var plo = PlayerObservable.plo
    @ObservedObject var lgo = LoginObservable.shared
    @ObservedObject var cha = ChannelsObservable.shared
    
    //It's a long one line but it works
    var channelSearchResults: [iptvChannel] {
        (cha.chan.filter({ $0.categoryID == categoryID })
            .filter({"\($0.num)\($0.name)\($0.nowPlaying)"
            .lowercased()
            .contains(searchText.lowercased()) || searchText.isEmpty}))
    }
    
    var isMac: Bool {
        UIDevice.current.userInterfaceIdiom == .mac
    }
    
    func isEven(_ f: Int) -> Bool {
        f % 2 == 0
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            Form {
                
                Section(header: Text("Channels").foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold))) {
                    ForEach(Array(channelSearchResults),id: \.id) { ch in
                        
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            
                            Group {
                                
                                NavigationLink(destination: PlayerView()) {
                                    HStack {
                                        Text(String(ch.num))
                                            .fontWeight(.medium)
                                            .font(.system(size: 24, design: .monospaced))
                                            .frame(minWidth: 40, idealWidth: 80, alignment: .trailing)
                                        
                                    }
                                    VStack (alignment: .leading, spacing: 0) {
                                        Text(ch.name)
                                            .font(.system(size: 16, design: .default))
                                            .fontWeight(.regular)
                                        
                                        if !ch.nowPlaying.isEmpty {
                                            Text(ch.nowPlaying)
                                                .font(.system(size: 14, design: .default))
                                                .fontWeight(.light)
                                        }
                                    }
                                    .padding(.leading, 7.5)
                                    .frame(alignment: .center)
                                    
                                }.listRowBackground(self.selectedItem == ch.streamID || (plo.previousStreamID == ch.streamID && self.selectedItem == nil) ? Color("iptvTableViewSelection") : Color("iptvTableViewBackground"))
                            }
                         
 
                        
                        } else {
                            HStack {
                                
                                HStack {
                                    Text(String(ch.num))
                                        .fontWeight(.medium)
                                        .font(.system(size: 24, design: .monospaced))
                                        .frame(minWidth: 45, idealWidth: 80, alignment: .trailing)
                                }
                                
                                
                                VStack (alignment: .leading, spacing: 0) {
                                    Text(ch.name)
                                        .font(.system(size: 16, design: .default))
                                        .fontWeight(.regular)
                                        .multilineTextAlignment(.leading)
                                    
                                    if !ch.nowPlaying.isEmpty {
                                        Text(ch.nowPlaying)
                                            .font(.system(size: 14, design: .default))
                                            .fontWeight(.light)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                
                                
                                
                                
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color.primary)
                            .frame(width:.infinity, height:.infinity)
                            .contentShape(Rectangle())
                            .simultaneousGesture(TapGesture().onEnded{
                                Player.iptv.Action(streamId: ch.streamID, channelName: ch.name, imageURL: ch.streamIcon)
                            })
                            .listRowBackground(self.selectedItem == ch.streamID ? Color("iptvTableViewSelection") : Color("iptvTableViewBackground"))
                        }
                        
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Channels")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Channels")
            .padding(.leading, isMac ? -20 : 0)
            .padding(.trailing,isMac ? -20 : 0)
            .frame(width: .infinity, alignment: .trailing)
            .edgesIgnoringSafeArea(.all)
            .onAppear{
                // if plo.streamID > 0 && plo.videoController.player?.rate == 1 {
                //     self.selectedItem = plo.streamID
                // }
            }
        }
    }
    
    func performMagicTapStop() {
        plo.videoController.player?.pause()
    }
    
   
}



public class Player: NSObject {
    
    var plo = PlayerObservable.plo
    var lgo = LoginObservable.shared
    var cha = ChannelsObservable.shared
    
    
    static public let iptv = Player()
    public func Action(streamId: Int, channelName: String, imageURL: String) {
        
        
        
       
        plo.previousStreamID = streamId
//   plo.streamID = streamId
        
        // if plo.previousStreamID != streamId {
        nowPlaying(channelName: channelName, streamId: streamId, imageURL: imageURL)
        airPlayr(streamId: streamId)
        // }
        
        
    }
    
    func nowPlaying(channelName: String, streamId: Int, imageURL: String) {
        plo.channelName = channelName
        plo.streamID = streamId
        plo.imageURL = imageURL
        getShortEpg(streamId: streamId, channelName: channelName, imageURL: imageURL)
    }
    
    func airPlayr(streamId: Int) {
        
        let good: String = lgo.username
        let time: String = lgo.password
        let todd: String = lgo.config?.serverInfo.url ?? "primestreams.tv"
        let boss: String = lgo.config?.serverInfo.port ?? "826"
        
        let primaryUrl = URL(string:"https://starplayrx.com:8888/\(todd)/\(boss)/\(good)/\(time)/\(streamId)/hlsx.m3u8")
        let backupUrl = URL(string:"http://localhost:\(hlsxPort)/\(plo.streamID)/hlsx.m3u8")
        let airplayUrl = URL(string:"http://\(todd):\(boss)/live/\(good)/\(time)/\(streamId).m3u8")
        
        guard
            let primaryUrl = primaryUrl,
            let backupUrl = backupUrl,
            let airplayUrl = airplayUrl
                
        else { return }
        
        func playUrl(_ streamUrl: URL) {
            DispatchQueue.main.async {
                let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true, AVURLAssetAllowsCellularAccessKey : true, AVURLAssetAllowsExpensiveNetworkAccessKey : true, AVURLAssetAllowsConstrainedNetworkAccessKey : true, AVURLAssetReferenceRestrictionsKey: true ]
                
                let playNowUrl = avSession.currentRoute.outputs.first?.portType == .airPlay || self.plo.videoController.player!.isExternalPlaybackActive ? airplayUrl : streamUrl
                
                self.plo.streamID = streamId
                
                let asset = AVURLAsset.init(url: playNowUrl, options:options)
                let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
                self.plo.videoController.player?.replaceCurrentItem(with: playerItem)
                self.plo.videoController.player?.playImmediately(atRate: 1.0)
            }
        }
        
        func starPlayrHLSx() {
            rest.textAsync(url: "https://starplayrx.com:8888/eHRybS5tM3U4") { hlsxm3u8 in
                let decodedString = (hlsxm3u8?.base64Decoded ?? "This is a really bad error 1.")
                primaryUrl.absoluteString.contains(decodedString) ? playUrl(primaryUrl) : localHLSx()
            }
        }
        
        func localHLSx() {
            rest.textAsync(url: "http://localhost:\(hlsxPort)/eHRybS5tM3U4/") { hlsxm3u8 in
                let decodedString = (hlsxm3u8?.base64Decoded ?? "This is a really bad error 2.")
                backupUrl.absoluteString.contains(decodedString) ? playUrl(backupUrl) : playUrl(airplayUrl)
            }
        }
        
        starPlayrHLSx()
    }
    
}
