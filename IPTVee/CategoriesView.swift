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
    
    @State var isActive: Bool = false
    @State var selectedItem: String?
    @State var toggleBackground: Bool = false
    @ObservedObject var plo = PlayerObservable.plo
    @ObservedObject var lgo = LoginObservable.shared
    @Environment(\.colorScheme) var colorScheme
    
    let usaKey = "usa"
    @State var searchText: String = ""

    var categorySearchResults: Categories {
        let main = cats
            .filter { $0.categoryName.lowercased().contains(searchText.lowercased() ) || searchText.isEmpty }
            .sorted { $0.categoryName.lowercased() < $1.categoryName.lowercased() }
        let usa = main
            .filter { $0.categoryName.lowercased().starts(with: usaKey) }
        let other = main
            .filter { !$0.categoryName.lowercased().starts(with: usaKey) }
        return usa + other
    }
    
    @State var isPortrait: Bool = false
    
    var body: some View {
        if !lgo.isLoggedIn {
            
            VStack {
                AboutScreenView()
                Button(action: {lgo.showingLogin = true}) {
                    Text("Login")
                }
                Spacer()
            }
            
        } else {
            NavigationView {
                Form {
                    ForEach(Array(categorySearchResults),id: \.categoryID) { cat in
                        NavigationLink(destination: ChannelsView(categoryID: cat.categoryID, categoryName: cat.categoryName)) {
                            HStack {
                                
                                //MARK: - To Do, do this elsewhere
                                if let catName = Optional(cat.categoryName), let cat = Optional("USA Movies Channels"), (catName == cat), let mov = Optional("USA Movie Channels") {
                                    
                                    Text(mov)
                                        .font(.system(size: 20, design: .default))
                                        .fontWeight(.medium)
                                        .fixedSize(horizontal: false, vertical: true)
                                } else {
                                    Text(cat.categoryName)
                                        .font(.system(size: 20, design: .default))
                                        .fontWeight(.medium)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .foregroundColor(plo.previousCategoryID == cat.categoryID ? Color.white : Color.primary)
                            .padding(0)
                            //.edgesIgnoringSafeArea([.all])
                        }
                        .isDetailLink(true)
                        .listRowSeparator(plo.previousCategoryID == cat.categoryID ? .hidden : .visible)
                        .listRowBackground(plo.previousCategoryID == cat.categoryID ? Color.accentColor : colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                    }
                }
                .padding(.bottom, 10)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")
                .disableAutocorrection(true)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("IPTVee")
                if isPad && isPortrait {
                    VStack {
                        
                        Spacer()
                        
                        Text("Press the back button for Categories and Channels.")
                        
                        Spacer()
                    }
                    .padding(.bottom, 45)
                }
    
            }
            .padding(.top, -10)
            
        }
    }
}

