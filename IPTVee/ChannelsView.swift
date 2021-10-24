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
    
    let epgTimer = Timer.publish(every: 60, on: .current, in: .default).autoconnect()
    
    var body: some View {
        
        GeometryReader { geometry in
            Form {
                
                Section(header: Text("CHANNELS")) {
                    ForEach(Array(channelSearchResults),id: \.id) { ch in
                        let channelItem = "\(ch.name)"
                        let channelNumber = "\(ch.num)"
                        let url = URL(string:"http://\(lgo.url):\(lgo.port)/live/\(lgo.username)/\(lgo.password)/\(ch.streamID).m3u8")

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
                                
            }.onDisappear{
                
                if selectedItem != nil {
                    plo.previousStreamID = selectedItem
                } else {
                    selectedItem = plo.previousStreamID
                }
            }
            .onReceive(epgTimer) { _ in
                if plo.videoController.player?.rate == 1 {
                    let min = Int(Calendar.current.component(.minute, from: Date()))
                    min % 6 == 0 || min % 6 == 3 ? getShortEpg(streamId: plo.streamID, channelName: plo.channelName, imageURL: plo.imageURL) : ()
                    min % 6 == 0 || min % 6 == 3 ? getNowPlayingEpg(channelz: ChannelsObservable.shared.chan) : ()
                } else {
                    let min = Calendar.current.component(.minute, from: Date())
                    min % 6 == 0 || min % 6 == 3 ? getNowPlayingEpg(channelz: ChannelsObservable.shared.chan) : ()
                }
            }
            #if !targetEnvironment(macCatalyst)
            .refreshable {
                getNowPlayingEpg(channelz: ChannelsObservable.shared.chan)
            }
            #endif
            
            
            if #available(iOS 15.0, *) {
                #if !targetEnvironment(macCatalyst)
                Text("")
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Channels")
                #endif
            }
        }
    }
    
    func performMagicTapStop() {
        plo.videoController.player?.pause()
    }
}
