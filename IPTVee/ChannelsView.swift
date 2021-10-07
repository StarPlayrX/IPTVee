//
//  ChannelsView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/1/21.
//

import SwiftUI
import iptvKit
import AVKit

class ChannelsObservable: ObservableObject {
    static var shared = ChannelsObservable()
}

struct ChannelsView: View {
    
    internal init(categoryID: String, categoryName: String) {
        self.categoryID = categoryID
        self.categoryName = categoryName
    }
    
    let categoryID: String
    let categoryName: String
    @State var searchText: String = ""
    @State var selectedChannel: String?
    @FocusState var isFocused
    @State var isActive: Bool = false
    
    @ObservedObject var plo = PlayerObservable.plo
    
    //It's a long one line but it works
    var channelSearchResults: [iptvChannel] {
        chan.filter({ $0.categoryID == categoryID })
            .filter({"\($0.num)\($0.name)"
            .lowercased()
                .contains(searchText.lowercased()) || searchText.isEmpty})
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            List {
                
                // DEMO VIDEO
                Section(header: Text("HACKING WITH SWIFT")) {
                    NavigationLink("A NEW HOPE USING SWIFTUI", destination: PlayerView(channelName: "HACKING WITH SWIFT", streamId: String("HWS"), playerView: AVPlayerView(streamId: String("HWS") )))
                }
                
                Section(header: Text("CHANNELS")) {
                    ForEach(Array(channelSearchResults),id: \.streamID) { ch in
                        let channelItem = "\(ch.num) \(ch.name)"

                        //MARK: - Todo Add Channel Logos { create backend code, and it download as a data file with bytes or SHA256 checksum }
                        //MARK: - Todo Electronic Program Guide, EPG -> Now Playing { add to filter }
                        NavigationLink(channelItem, destination: PlayerView(channelName: ch.name, streamId: String(ch.streamID), playerView: AVPlayerView(streamId: String(ch.streamID) )))
                    }
                }

            }
            .searchable(text: $searchText, placement: .automatic, prompt: "Search Channels")
            .navigationTitle(categoryName)
            .frame(width: geometry.size.width)
        }
    }
}
