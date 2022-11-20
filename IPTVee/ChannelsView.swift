//
//  ChannelsView.swift
//  IPTVee
//
//  Created by Todd Bruss on 10/1/21.
//

import SwiftUI
import iptvKit
import AVKit

let epgLongTimer = Timer.publish(every: 60, on: .current, in: .default).autoconnect()

struct ChannelsView: View {
    
    internal init(categoryID: String, categoryName: String) {
        self.categoryID = categoryID
        self.categoryName = categoryName
    }
    
    let usa = "USA "
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
            .filter{"\($0.num)\($0.name)\(cha.nowPlayingLive[$0.epgChannelID ?? ""]?.first?.title ?? "")"
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
                
                NavigationLink(destination: PlayerView(streamID: ch.streamID, name: ch.name, streamIcon: ch.streamIcon, categoryName: categoryName, epgChannelId: ch.epgChannelID ))  {
                    

                    HStack {
                        Text(String(ch.num))
                            .fontWeight(.bold)
                            .font(.system(size: 20, design: .default))
                            .frame(minWidth: 60, idealWidth: 80, alignment: .trailing)
                            .fixedSize(horizontal: false, vertical: true)
                        VStack (alignment: .leading, spacing: 0) {
                            Text(ch.name.deletingPrefix(usa))
                                .font(.system(size: 19, design: .default))
                                .fontWeight(.semibold)
                                .fixedSize(horizontal: false, vertical: true)
                            LazyVStack (alignment: .leading, spacing: 0) {
                                if let npl = cha.nowPlayingLive[ch.epgChannelID ?? ""]?.first,
                                   let start = npl.start.toDate()?.toString(),
                                   let stop = npl.stop.toDate()?.toString() {
                                    Text("\(start) — \(stop)\n\(npl.title)")
                                        .font(.system(size: 18, design: .default))
                                        .fontWeight(.regular)
                                        .fixedSize(horizontal: false, vertical: true)
                                } else if let epgId = ch.epgChannelID {
                                    Text("\(epgId)")
                                        .foregroundColor(plo.previousStreamID == ch.streamID ? Color.white : Color.orange)
                                        .font(.system(size: 15, design: .default))
                                        .fontWeight(.regular)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .foregroundColor(plo.previousStreamID == ch.streamID ? Color.white : Color.primary)
                }
                .isDetailLink(false)
                .listRowBackground(plo.previousStreamID == ch.streamID ? Color.accentColor : colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
            }
        }
        .padding(.bottom, 10)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search \(categoryName)")
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .onReceive(epgLongTimer) { _ in
            refreshNowPlayingEpg()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            refreshNowPlayingEpgBytes()
        }
        .refreshable {
            refreshNowPlayingEpgBytes()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(categoryName)
        .onAppear {
            plo.previousCategoryID = categoryID
            refreshNowPlayingEpgBytes()

        }
    }
    
    func performMagicTapStop() {
        pvc.videoController.player?.pause()
    }
}
