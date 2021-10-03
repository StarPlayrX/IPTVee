//
//  ChannelsView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/1/21.
//

import Foundation
import SwiftUI

class ChannelsObservable: ObservableObject {
    static var shared = ChannelsObservable()
}

struct ChannelsView: View {
    @ObservedObject var cos = ChannelsObservable.shared
    @ObservedObject var plo = PlayerObservable.plo
    
    let categoryID: String
    
    var body: some View {
    
        Form {
            Section(header: Text("CHANNELS")) {
                
                //MARK: Todo - Add a search bar and work the filter in with it
                let category = chan.filter({ $0.categoryID == categoryID })
                
                ForEach(Array(category),id: \.name) { ch in
                    
                    HStack {
                        //MARK: - Todo Add Channel Logos { create backend code, and it download as a data file with bytes or SHA256 checksum }
                        //MARK: - Todo Electronic Program Guide, EPG - Now Playing { filter }
                        NavigationLink(String(ch.num) + " " + ch.name,destination: PlayerView(streamId: String(ch.streamID), channelName: ch.name))
                    }
                    .foregroundColor(.white)

                }
            }
            .navigationTitle("Channels")
            
        }
        .onAppear(perform: { AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait })
    }
}
