//
//  CategoriesView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/28/21.
//

import SwiftUI
import iptvKit

struct CategoriesView: View {
    @ObservedObject var obs = iptvKit.LoginObservable.shared
    
    @State var searchText: String = ""
    @State var isActive: Bool = false

    // This is our search filter
    var categorySearchResults: Categories {
        cats.filter({"\($0.categoryName)"
            .lowercased()
            .contains(searchText.lowercased()) || searchText.isEmpty})
    }
    
    var body: some View {
        
        Form {
            Section(header: Text("CATEGORIES")) {
                
                ForEach(Array(categorySearchResults),id: \.categoryName) { cat in
                    HStack {
                        NavigationLink(cat.categoryName,destination: ChannelsView(categoryID: cat.categoryID, categoryName: cat.categoryName))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Categories")
        }
        #if !targetEnvironment(macCatalyst)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")
        #endif
        .onAppear {
            AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
        }
        
    }
}
