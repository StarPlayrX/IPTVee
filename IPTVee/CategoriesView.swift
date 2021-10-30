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
        
        
        NavigationView {
            
                    
                   
                    
                    
                    Form {
                        
                        Section(header: Text("LIST")) {
                            Button("Login") {
                                obs.showingLogin = true
                            }
                            .sheet(isPresented: $obs.showingLogin) {
                                LoginSheetView()
                            }
                        }
                      
                        
                        
                        
                        Section(header: Text("CATEGORIES")) {
                            
                            ForEach(Array(categorySearchResults),id: \.categoryID) { cat in
                                NavigationLink(cat.categoryName, destination: ChannelsView(categoryID: cat.categoryID, categoryName: cat.categoryName), tag: cat.categoryID, selection: self.$selectedItem)
                                    .isDetailLink(false)
                                    .listRowBackground(self.selectedItem == cat.categoryID || (plo.previousCategoryID == cat.categoryID && self.selectedItem == nil) ? Color("iptvTableViewSelection") : Color("iptvTableViewBackground"))
                            }
                        }
                        
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarTitle("Categories")
                    }
                    .padding(.top, -20)
                    .padding(.leading, -20)
                    .padding(.trailing, -20)
                    .frame(width: .infinity, alignment: .trailing)
                    .edgesIgnoringSafeArea(.all)
                    
                    
                    .onAppear {
                        AppDelegate.interfaceMask = UIInterfaceOrientationMask.allButUpsideDown
                    }
                    .onDisappear{
                        print("HELLO")
                        if selectedItem != nil {
                            plo.previousCategoryID = selectedItem
                        }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")

        
        }
        .edgesIgnoringSafeArea(.all)
        .navigationViewStyle(.columns)
        
        
        
    }
}
