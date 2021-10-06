//
//  ChannelsView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/1/21.
//

import SwiftUI
import iptvKit

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
    var channelSearchResults: [Channel] {
        chan.filter({ $0.categoryID == categoryID })
            .filter({"\($0.num)\($0.name)"
            .lowercased()
                .contains(searchText.lowercased()) || searchText.isEmpty})
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            Form {
                Section(header: Text("CHANNELS")) {
                    
                    ForEach(Array(channelSearchResults),id: \.streamID) { ch in
                        
                        let channelItem = "\(ch.num) \(ch.name)"

                        //MARK: - Todo Add Channel Logos { create backend code, and it download as a data file with bytes or SHA256 checksum }
                        //MARK: - Todo Electronic Program Guide, EPG -> Now Playing { add to filter }
                        NavigationLink(channelItem,destination: PlayerView(streamId: String(ch.streamID), channelName: ch.name))
                            //.onTapGesture {
                            //    selectedChannel = channelItem
                            //}
                            //.listRowBackground(selectedChannel == channelItem ? Color(UIColor.systemBlue) : Color(UIColor.systemGray6))

                        
                    }
                    
                }
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "Search Channels")
            .navigationTitle(categoryName)
            .frame(width: geometry.size.width)
        }
        .onAppear {
            plo.fullScreenTriggered = true
            AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
        }
        .onDisappear {
            plo.fullScreenTriggered = false
        }
    }
}

/*
 
 Button(action: {
 self.selectedGroup = group
 }, label: {
 Text(group.name)
 })
 .listRowBackground(self.selectedGroup == group ? Color.gray : Color(UIColor.systemGroupedBackground))
 
 */
