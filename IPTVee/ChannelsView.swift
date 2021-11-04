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
    var playerView = PlayerView()
    
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
    @Environment(\.presentationMode) var presentationMode
    
    //It's a long one line but it works
    var channelSearchResults: [iptvChannel] {
        (cha.chan.filter({ $0.categoryID == categoryID })
            .filter({"\($0.num)\($0.name)\($0.nowPlaying)"
            .lowercased()
            .contains(searchText.lowercased()) || searchText.isEmpty}))
    }
    
    @State var isShowingColumn = true
    
    @State var isPortrait: Bool = false
    
    var isPortraitFallback: Bool {
        guard let scene =  (UIApplication.shared.connectedScenes.first as? UIWindowScene) else {
            return true
        }
        
        return scene.interfaceOrientation.isPortrait
    }
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    var isMac: Bool {
        #if targetEnvironment(macCatalyst)
        true
        #else
        false
        #endif
    }
    
    func isEven(_ f: Int) -> Bool {
        f % 2 == 0
    }
    
    
    fileprivate func getOrientation() {
        if UIDevice.current.orientation.isPortrait { isPortrait = true; return}
        if UIDevice.current.orientation.isLandscape { isPortrait = false; return}
        
        isPortrait = isPortraitFallback
    }
    
    var body: some View {
        
        Form {
            
            Group {
                ForEach(Array(channelSearchResults),id: \.id) { ch in
                    
                    Group {
                        
                        NavigationLink(destination: playerView, tag: "\(ch.streamID)^\(ch.name)^\(ch.streamIcon)", selection: self.$selectedItem)  {
                            HStack {
                                Text(String(ch.num))
                                    .fontWeight(.medium)
                                    .font(.system(size: 24, design: .monospaced))
                                    .frame(minWidth: 40, idealWidth: 80, alignment: .trailing)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                            }
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
                        .isDetailLink(true)
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            RoundedRectangle(
                                cornerRadius: 9,
                                style: .continuous
                            )
                           
                            .fill(plo.previousSelection == "\(ch.streamID)^\(ch.name)^\(ch.streamIcon)" ? Color("iptvTableViewSelection") : Color.clear)

                        )
                    
                    }
             

                }
            }
            .onChange(of: selectedItem) { selectionData in
                if plo.previousSelection != selectionData || plo.previousSelection != selectedItem {
                    if let elements = selectionData?.components(separatedBy: "^"), elements.count == 3, let sd = selectionData  {
                        plo.previousSelection = sd
                        plo.channelName =  elements[1]

                        PlayerObservable.plo.miniEpg = []
                        Player.iptv.Action(streamId: Int(elements[0]) ?? 0, channelName: elements[1], imageURL:  elements[2])
                        
                      //  if isPhone && !isPortrait { selectedItem = nil }
                      //  if isPad {selectedItem = nil }
                    }
                }
            }
        }
        .padding([.top], isMac ? 0 : -40)
        .edgesIgnoringSafeArea([.top])

     
        
        #if targetEnvironment(macCatalyst)
        .listStyle(GroupedListStyle())
        #else
        .listStyle(InsetGroupedListStyle())
        .refreshable  {
            DispatchQueue.main.async {
                getNowPlayingEpg()
            }
        }
        #endif
        
        .frame(width: .infinity, alignment: .trailing)
        .edgesIgnoringSafeArea([.leading, .trailing])
        .navigationBarTitleDisplayMode(.inline)

        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search \(categoryName)")
        .navigationTitle(categoryName)
        .onAppear{getOrientation()}
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            getOrientation()
        }
        
    }
    
    
    func performMagicTapStop() {
        plo.videoController.player?.pause()
    }
    
}




