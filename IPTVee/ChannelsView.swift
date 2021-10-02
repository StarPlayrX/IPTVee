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
    var isAutoSwitchCat: Bool = false

}

struct ChannelsView: View {
    @ObservedObject var cos = ChannelsObservable.shared
    
    func resignActive() {
        cos.isAutoSwitchCat.toggle()
    }
    
    var body: some View {
        
        Form {
            Section(header: Text("CHANNELS")) {
                
                ForEach(Array(chan),id: \.name) { ch in
                    
                    HStack {
                        NavigationLink(String(ch.num) + " " + ch.name,destination: PlayerView())
                            .foregroundColor(.white)
                    }
                }
            }.navigationTitle("Channels")
            
        }.onAppear(perform: { resignActive() })
    }
}

