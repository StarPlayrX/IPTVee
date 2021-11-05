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
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
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
                Form {
                    ForEach(Array(categorySearchResults),id: \.categoryID) { cat in
                        NavigationLink(destination: ChannelsView(categoryID: cat.categoryID, categoryName: cat.categoryName), tag: cat.categoryID, selection: $selectedItem) {
                            HStack {
                                Text(cat.categoryName)
                                
                                if 1 == 2 {
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")                     // << custom !!
                                        .foregroundColor((plo.previousCategoryID == cat.categoryID ? Color.white : Color.accentColor))
                                }
                            }
                            .padding(0)
                            .edgesIgnoringSafeArea([.all])
                        }
                        .isDetailLink(false)
                        .listRowSeparator(.hidden)
                        .listRowBackground(
                            RoundedRectangle(
                                cornerRadius: 9,
                                style: .continuous
                            )
                                .fill(plo.previousCategoryID == cat.categoryID ? Color.accentColor : Color.clear)
                        )
                    }
                }
                .padding(.top, -20)
                .onChange(of: selectedItem) { selectionData in
                    if plo.previousCategoryID != selectionData, let sd = selectionData {
                        plo.previousCategoryID = sd
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("IPTVee")
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")
                .listStyle(.sidebar)
                .edgesIgnoringSafeArea([.all])
                
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

