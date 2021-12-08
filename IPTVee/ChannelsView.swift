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
    @ObservedObject var pvc = PlayerViewControllerObservable.pvc
    @Environment(\.presentationMode) var presentationMode
    
    //It's a long one line but it works
    var channelSearchResults: [iptvChannel] {
        cha.chan
            .filter{$0.categoryID == categoryID}
            .filter{"\($0.num)\($0.name)\($0.nowPlaying)"
            .lowercased()
            .contains(searchText.lowercased()) || searchText.isEmpty}
            .sorted{$0.num < $1.num}
    }
    
    @State var isShowingColumn = true
    var isPortrait: Bool {
        if UIDevice.current.orientation.isPortrait { return true}
        if UIDevice.current.orientation.isLandscape { return false}
        return isPortraitFallback
    }
    
    var isPortraitFallback: Bool {
        guard let scene =  (UIApplication.shared.connectedScenes.first as? UIWindowScene) else {
            return true
        }
        return scene.interfaceOrientation.isPortrait
    }

    var body: some View {
        
        
        Form {
            ForEach(Array(channelSearchResults),id: \.id) { ch in
                
                NavigationLink(destination: PlayerView(streamID: ch.streamID, name: ch.name, streamIcon: ch.streamIcon, categoryName: categoryName))  {
                    
                    HStack {
                        Text(String(ch.num))
                            .fontWeight(.medium)
                            .font(.system(size: 24, design: .monospaced))
                            .frame(minWidth: 40, idealWidth: 80, alignment: .trailing)
                            .fixedSize(horizontal: false, vertical: true)
                        VStack (alignment: .leading, spacing: 0) {
                            Text(ch.name)
                                .font(.system(size: 16, design: .default))
                                .fontWeight(.regular)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if !ch.nowPlaying.isEmpty {
                                Text(ch.nowPlaying)
                                    .font(.system(size: 14, design: .default))
                                    .fontWeight(.light)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(alignment: .center)
                    }
                    .foregroundColor(plo.previousStreamID == ch.streamID ? Color.white : Color.primary)
                }
                .isDetailLink(false)
                .listRowBackground(plo.previousStreamID == ch.streamID ? Color.accentColor : colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search \(categoryName)")
        .disableAutocorrection(true)
        .refreshable {
            DispatchQueue.main.async() {
                getNowPlayingEpg()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(categoryName)
        .onAppear{
            plo.previousCategoryID = categoryID
        }
    }
    
    func performMagicTapStop() {
        pvc.videoController.player?.pause()
    }
}
