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
    @State var selectedItem: String?
    @ObservedObject var plo = PlayerObservable.plo
    
    // This is our search filter
    var categorySearchResults: Categories {
        cats.filter({"\($0.categoryName)"
                .lowercased()
            .contains(searchText.lowercased()) || searchText.isEmpty})
    }
    
    var body: some View {
        
        Text("")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")

        Form {
            
            Section(header: Text("CATEGORIES")) {
                
                ForEach(Array(categorySearchResults),id: \.categoryID) { cat in
                    NavigationLink(cat.categoryName, destination: ChannelsView(categoryID: cat.categoryID, categoryName: cat.categoryName), tag: cat.categoryID, selection: self.$selectedItem)
                        .listRowBackground(self.selectedItem == cat.categoryID || (plo.previousCategoryID == cat.categoryID && self.selectedItem == nil) ? Color("iptvTableViewSelection") : Color("iptvTableViewBackground"))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Categories")
        }
        
     
        .onAppear {
            AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
        }
        .onDisappear{
            if selectedItem != nil {
                plo.previousCategoryID = selectedItem
            }
        }
    }
}
