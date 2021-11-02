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
    @State var selectedItem: String?
    @State var runningMan: Bool = false
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
        #if targetEnvironment(macCatalyst)
            true
        #else
            false
        #endif
    }
    
    func isEven(_ f: Int) -> Bool {
        f % 2 == 0
    }
    
    @State var playerView = PlayerView()

    
    var body: some View {

            
            Form {
                
                Section(header: Text("Channels").foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold))) {
                    ForEach(Array(channelSearchResults),id: \.id) { ch in
                        
                        
                        Group {
                            
                            NavigationLink(destination: playerView, tag: "\(ch.streamID)^\(ch.name)^\(ch.streamIcon)", selection: self.$selectedItem)  {
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
                                
                            }
                            .isDetailLink(true)
                            .listRowBackground(self.selectedItem == "\(ch.streamID)^\(ch.name)^\(ch.streamIcon)" || plo.previousSelection == "\(ch.streamID)^\(ch.name)^\(ch.streamIcon)" ? Color("iptvTableViewSelection") : Color("iptvTableViewBackground"))
                        }
                        
                        
                    }
                }
                .onChange(of: selectedItem) { selectionData in
                    if let elements = selectionData?.components(separatedBy: "^"), elements.count == 3, let sd = selectionData  {
                        Player.iptv.Action(streamId: Int(elements[0]) ?? 0, channelName: elements[1], imageURL:  elements[2])
                        plo.previousSelection = sd
                    }
                 
                }
              
            }
            .transition(.opacity)

            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Channels")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Channels")
            .padding(.leading, isMac ? -20 : 0)
            .padding(.trailing,isMac ? -20 : 0)
            .frame(width: .infinity, alignment: .trailing)
            .edgesIgnoringSafeArea(.all)
       
        
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
