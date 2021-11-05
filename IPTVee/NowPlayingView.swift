//
//  NowPlayingView.swift
//  IPTVee
//
//  Created by M1 on 11/4/21.
//

import SwiftUI
import iptvKit

extension Text {
    func SectionHeader(_ isMac: Bool) -> some View {
        self.offset(y: isMac ? 12 : 0)
            .foregroundColor(Color.secondary)
            .font(.system(size: isMac ? 14 : 17, weight: .bold))
    }
}

struct NowPlayingView: View {
    @ObservedObject var plo = PlayerObservable.plo
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
     
   @State var isPortrait: Bool = true
    
    var body: some View {
        VStack {
            Form {
                if !plo.miniEpg.isEmpty && (isPortrait || isMac ) {
                    
                    Section(header: Text("Program Guide").SectionHeader(isMac)) {
                        ForEach(Array(plo.miniEpg),id: \.id) { epg in
                            
                            HStack {
                                Text(epg.start.toDate()?.userTimeZone().toString() ?? "")
                                    .fontWeight(.medium)
                                    .frame(minWidth: 78, alignment: .trailing)
                                    .multilineTextAlignment(.leading)
                                
                                Text(epg.title.base64Decoded ?? "")
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading, 5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .listRowSeparator(isMac ? .hidden : .visible)
                            .font(.callout)
                        }
                    }  
                    if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3 {
                        Section(header: Text("Description").SectionHeader(isMac))  {
                            Text(desc)
                                .frame(minWidth: 80, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                        }
                    } else if (isPhone || isMac || isPad)  {
                        Section(header: Text("Description").SectionHeader(isMac)) {
                            Text(plo.channelName)
                                .font(.body)
                                .fontWeight(.light)
                                .frame(minWidth: 80, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                } else if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3 {
                    
                    HStack {
                        Text(plo.miniEpg.first?.start.toDate()?.userTimeZone().toString() ?? "")
                            .fontWeight(.medium)
                            .frame(minWidth: 78, alignment: .trailing)
                            .multilineTextAlignment(.leading)
                        
                        Text(plo.miniEpg.first?.title.base64Decoded ?? "")
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 5)
                    }
                    .font(.callout)
                    
                    if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3 {
                        Text(desc)
                            .frame(minWidth: 80, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    } else if (isPhone || isMac)  {
                        Text(plo.channelName)
                            .font(.body)
                            .fontWeight(.light)
                            .frame(minWidth: 80, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}
