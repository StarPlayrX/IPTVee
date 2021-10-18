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
        .onAppear {
            AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
        }
        
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            Text("")
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")
        }
    }
}
