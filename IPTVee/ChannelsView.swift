//
//  ChannelsView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/1/21.
//

import SwiftUI

class ChannelsObservable: ObservableObject {
    static var shared = ChannelsObservable()
}

struct ChannelsView: View {
    internal init(categoryID: String) {
        self.categoryID = categoryID
    }
    
    
    let categoryID: String
    @ObservedObject var plo = PlayerObservable.plo

    
    var body: some View {
        
        let category = chan.filter({ $0.categoryID == categoryID })
        GeometryReader { geometry in
            List {
                Section(header: Text("CATEGORIES")) {
                    
                    ForEach(Array(category),id: \.streamID) { ch in
                        //MARK: - Todo Add Channel Logos { create backend code, and it download as a data file with bytes or SHA256 checksum }
                        //MARK: - Todo Electronic Program Guide, EPG - Now Playing { filter }
                        
                        //MARK: - To Fix: ForEach<Array<Channel>, String, NavigationLink<Text, PlayerView>>:
                        //MARK: the ID EVENTS 42: occurs multiple times within the collection, this will give undefined results!
                        NavigationLink(String(ch.num) + " " + ch.name,destination: PlayerView(streamId: String(ch.streamID), channelName: ch.name))
                        
                        
                    }
                }
            }
            
            .navigationTitle("Channels")
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


