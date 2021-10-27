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
    
    var body: some View {
        
        GeometryReader { geometry in
            
            Text("")
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Channels")

            Form {
                    
                Section(header: Text("CHANNELS")) {
                    ForEach(Array(channelSearchResults),id: \.id) { ch in
                        let channelItem = "\(ch.name)"
                        let channelNumber = "\(ch.num)"
                        //let url = URL(string:"http://localhost:\(hlsxPort)/\(ch.streamID)/playlist.m3u8")
                        
                        let good: String = lgo.username
                        let time: String = lgo.password
                        let todd: String = lgo.config?.serverInfo.url ?? "primestreams.tv"
                        let boss: String = lgo.config?.serverInfo.port ?? "826"
                        let url = URL(string:"http://starplayrx.com:9999/\(todd)/\(boss)/\(good)/\(time)/\(ch.streamID)/hlsx.m3u8")
                                             
                        NavigationLink(destination: PlayerView(url: url, channelName: ch.name, streamID: String(ch.streamID), imageUrl: ch.streamIcon ), tag: ch.streamID, selection: self.$selectedItem) {
                            HStack {
                                Text(channelNumber)
                                    .fontWeight(.medium)
                                    .font(.system(size: 24, design: .monospaced))
                                    .frame(minWidth: 40, idealWidth: 80, alignment: .trailing)
                                
                            }
                            VStack (alignment: .leading, spacing: 0) {
                                Text(channelItem)
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
                }
            }
            .accessibilityAction(.magicTap, {performMagicTapStop()})
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(categoryName)
            .frame(width: geometry.size.width)
            .onAppear {
                if plo.pip {
                    plo.fullscreen = false
                } else {
                    plo.miniEpg = []
                    plo.fullscreen = false
                }
            }.onDisappear {
                if selectedItem != nil {
                    plo.previousStreamID = selectedItem
                }
            }
            .refreshable {
                getNowPlayingEpg(channelz: ChannelsObservable.shared.chan)
            }
        }
    }
    
    func performMagicTapStop() {
        plo.videoController.player?.pause()
    }
}
