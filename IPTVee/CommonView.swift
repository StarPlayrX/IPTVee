//
//  CommonView.swift
//  IPTVee
//
//  Created by M1 on 11/2/21.
//

import SwiftUI
import iptvKit

struct CommonView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var searchText: String = ""
    @State var isActive: Bool = false
    @State var selectedItem: String?
    @State var toggleBackground: Bool = false
    @ObservedObject var plo = PlayerObservable.plo
    @ObservedObject var lgo = LoginObservable.shared
    
    // This is our search filter
    var categorySearchResults: Categories {
        cats.filter({"\($0.categoryName)"
                .lowercased()
            .contains(searchText.lowercased()) || searchText.isEmpty})
    }
    
    var isMac: Bool {
    #if targetEnvironment(macCatalyst)
        true
    #else
        false
        #endif
    }
    
    var body: some View {
        if !lgo.isLoggedIn {
            
            NavigationView {
                
                VStack {
                    AboutScreenView()

                   /* Button(action: {lgo.showingLogin = true}) {
                        Text("Login")
                    }*/
                    
                    Spacer()
                }
                
                
                VStack  {
                    AboutScreenView()
                    Text("")
                    Spacer()
                }
                .padding(.bottom, 45)

            }

    } else {
        NavigationView {
           
          
            Form {
                Group {
                    
                    EmptyView()
                        .frame(width: 0, height: 0, alignment: .center)
                    ForEach(Array(categorySearchResults),id: \.categoryID) { cat in
                        NavigationLink(cat.categoryName, destination: ChannelsView(categoryID: cat.categoryID, categoryName: cat.categoryName), tag: cat.categoryID, selection: $selectedItem)
                            .isDetailLink(false)
                            .listRowSeparator(.hidden)
                            .listRowBackground(
                                RoundedRectangle(
                                    cornerRadius: 10,
                                    style: .continuous
                                )
                               
                                .fill(plo.previousCategoryID == cat.categoryID  ? Color("iptvTableViewSelection") : Color.clear)

                            )
                    }
                }
                .onChange(of: selectedItem) { selectionData in
                    if plo.previousCategoryID != selectionData || plo.previousCategoryID != selectedItem, let sd = selectionData {
                        plo.previousCategoryID = sd
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("IPTVee")

            }
            .padding([.top], isMac ? 0 : -40)
            .edgesIgnoringSafeArea([.top])
            #if targetEnvironment(macCatalyst)
            .listStyle(GroupedListStyle())
            #else
            .listStyle(InsetGroupedListStyle())
            #endif
            .edgesIgnoringSafeArea([.leading, .trailing])
            
            
            VStack  {
                
                AboutScreenView()
                Text("")
                Spacer()
                
            }

            .padding(.bottom, 45)
        }


        
        .transition(.opacity)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")
    }
}
}

