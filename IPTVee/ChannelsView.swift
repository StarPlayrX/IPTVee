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
 
    
    var body: some View {
        
        Form {
            Section(header: Text("CHANNELS")) {
                
                ForEach(Array(chan),id: \.name) { ch in
                    
                    HStack {
                        NavigationLink(String(ch.num) + " " + ch.name,destination: PlayerView( url: "http://primestreams.tv:826/live/toddbruss90/zzeH7C0xdw/\(ch.streamID).m3u8"))
                            .foregroundColor(.white)
                    }
                }
            }.navigationTitle("Channels")
            
        }.onAppear(perform: { AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait })
    }
}

