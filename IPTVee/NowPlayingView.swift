//
//  NowPlayingView.swift
//  IPTVee
//
//  Created by M1 on 11/4/21.
//

import SwiftUI
import iptvKit

extension Text {
    func SectionHeader(_ isMac: Bool = false) -> some View {
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
    
    @State var categoryName: String = ""
    
    var body: some View {
        VStack {
            Form {
                if !plo.miniEpg.isEmpty {
                    
                    Section(header: Text("Program Guide").SectionHeader()) {
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
                            .listRowSeparator(.visible)
                            .font(.callout)
                        }
                    }
                    
                    if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3, updatePortrait() {
                        Section(header: Text("Description").SectionHeader())  {
                            Text(desc)
                                .frame(minWidth: 80, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            
                        }
                    }
                } else {
                    Section(header: Text("Description").SectionHeader()) {
                        HStack {
                            Text(categoryName + " ")
                                .font(.body)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(plo.channelName)
                                .font(.body)
                                .fontWeight(.light)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    
                    }
                }
                
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
}
