//
//  CategoriesView.swift
//  IPTVee
//
//  Created by M1 on 11/2/21.
//

import SwiftUI
import iptvKit

struct CategoriesView: View {
    
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
                    Button(action: {lgo.showingLogin = true}) {
                        Text("Login")
                    }
                    Spacer()
                }
                
                
                ZStack {
                    VStack {
                        AboutScreenView()
                        Button(action: {lgo.showingLogin = true}) {
                            Text("Login")
                        }
                        Spacer()
                    }
                }
            }
        } else {
            
    
            
            NavigationView {

                VStack {
                    Form {}
                    .frame(width: 0, height: 0)
                    List {
                        ForEach(Array(categorySearchResults),id: \.categoryID) { cat in
                            NavigationLink(cat.categoryName, destination: ChannelsView(categoryID: cat.categoryID, categoryName: cat.categoryName), tag: cat.categoryID, selection: $selectedItem)
                                .isDetailLink(false)
                                .listRowSeparator(.hidden)
                                .listRowBackground(
                                    RoundedRectangle(
                                        cornerRadius: isMac ? 8 : 10,
                                        style: .continuous
                                    )
                                    .fill(plo.previousCategoryID == cat.categoryID  ? Color.accentColor : Color.clear)
                                )
                                .foregroundColor(plo.previousCategoryID == cat.categoryID ? Color.white : Color.primary)
                            
                            
                        }
                        .onChange(of: selectedItem) { selectionData in
                            if plo.previousCategoryID != selectionData, let sd = selectionData {
                                plo.previousCategoryID = sd
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarTitle("IPTVee")
                    }
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")
                    .listStyle(.sidebar)
                    .edgesIgnoringSafeArea([.all])
                  
                }
               
                
                VStack {
                    AboutScreenView()
                    
                    Button(action: {lgo.showingLogin = true}) {
                        Text("Login")
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 45)
            }
            .padding(.top, -10)
            
        }
    }
}

