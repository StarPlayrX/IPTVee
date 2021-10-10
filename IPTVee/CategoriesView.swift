//
//  CategoriesView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/28/21.
//

import SwiftUI
import iptvKit

class CategoriesObservable: ObservableObject {
    static var cto = CategoriesObservable()
    @Published var status: String = "test"
    @Published var loggedIn: Bool = false
}

struct CategoriesView: View {
    @ObservedObject var obs = LoginObservable.shared
    
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
            }.navigationTitle("Categories")
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")

        .onAppear {
            AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
        }
        
    }
}
