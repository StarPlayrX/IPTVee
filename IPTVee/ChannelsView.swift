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
    
    @ObservedObject var plo = PlayerObservable.plo

    /*
     
     func getList(_ a: [ListItem], _ searchText: String) -> [ListItem] {
         a.filter({"\($0.emoji)\($0.name)".lowercased().contains(searchText.lowercased()) || searchText.isEmpty})
     }
     
     
     */
    

    var searchResults: [Channel] {
        let category = chan.filter({ $0.categoryID == categoryID })
        return category.isEmpty ? category : category.filter({"\($0.num)\($0.name)".lowercased().contains(searchText.lowercased()) || searchText.isEmpty})
    }
    
    var body: some View {
        
        
        GeometryReader { geometry in
            Form {
                Section(header: Text("CHANNELS")) {
                    
                    ForEach(Array(searchResults),id: \.streamID) { ch in
                        
                        let channelItem = "\(ch.num) \(ch.name)"

                        //MARK: - Todo Add Channel Logos { create backend code, and it download as a data file with bytes or SHA256 checksum }
                        //MARK: - Todo Electronic Program Guide, EPG -> Now Playing { filter }
                        NavigationLink(channelItem,destination: PlayerView(streamId: String(ch.streamID), channelName: ch.name))

                    }
                }
            }
            .searchable(text: $searchText)
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


