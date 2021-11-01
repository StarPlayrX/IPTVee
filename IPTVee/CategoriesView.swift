//  CategoriesView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/28/21.
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
        UIDevice.current.userInterfaceIdiom == .mac
    }
    
    
    var body: some View {
        
        
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            if !lgo.isLoggedIn {
                Text("")
                    .sheet(isPresented: $lgo.showingLogin) {
                        LoginSheetView()
                    }
            }
            
            NavigationView {
                
                Form {
                    Section(header: Text("Categories").foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold))) {
                        
                        EmptyView()
                            .frame(width: 0, height: 0, alignment: .center)
                        ForEach(Array(categorySearchResults),id: \.categoryID) { cat in
                            NavigationLink(cat.categoryName, destination: ChannelsView(categoryID: cat.categoryID, categoryName: cat.categoryName), tag: cat.categoryID, selection: self.$selectedItem)
                                .isDetailLink(false)
                                .padding(.leading, 2)
                                .padding(.trailing, 2)
                                .listRowBackground(self.selectedItem == cat.categoryID || (plo.previousCategoryID == cat.categoryID && self.selectedItem == nil) ? Color("iptvTableViewSelection") : Color("iptvTableViewBackground") )
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarTitle("Categories")
                }
                .padding(.leading, isMac ? -20 : 0)
                .padding(.trailing, isMac ? -20 : 0)
                .frame(width: .infinity, alignment: .trailing)
                .edgesIgnoringSafeArea(.all)
                
                .onAppear {
                    
                    if !plo.previousCategoryID.isEmpty && plo.videoController.player?.rate == 1 {
                        selectedItem = plo.previousCategoryID
                    }
                }
                .onDisappear{
                    if let si = selectedItem {
                        plo.previousCategoryID = si
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")
            }
            .onAppear {
                lgo.showingLogin = true
            }
            .navigationViewStyle(.stack)
            
            
            
          
        } else {
            NavigationView {
                
                Form {
                    Section(header: Text("Categories").foregroundColor(Color.secondary).font(.system(size: 17, weight: .bold))) {
                        
                        EmptyView()
                            .frame(width: 0, height: 0, alignment: .center)
                        ForEach(Array(categorySearchResults),id: \.categoryID) { cat in
                            NavigationLink(cat.categoryName, destination: ChannelsView(categoryID: cat.categoryID, categoryName: cat.categoryName), tag: cat.categoryID, selection: self.$selectedItem)
                                .isDetailLink(false)
                                .padding(.leading, 2)
                                .padding(.trailing, 2)
                                .listRowBackground(self.selectedItem == cat.categoryID || (plo.previousCategoryID == cat.categoryID && self.selectedItem == nil) ? Color("iptvTableViewSelection") : Color("iptvTableViewBackground") )
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarTitle("Categories")
                }
                .padding(.leading, isMac ? -20 : 0)
                .padding(.trailing, isMac ? -20 : 0)
                .frame(width: .infinity, alignment: .trailing)
                .edgesIgnoringSafeArea(.all)
                
                .onAppear {
                    
                    if !plo.previousCategoryID.isEmpty && plo.videoController.player?.rate == 1 {
                        selectedItem = plo.previousCategoryID
                    }
                }
                .onDisappear{
                    if let si = selectedItem {
                        plo.previousCategoryID = si
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Categories")
                
                PlayerView()
            }
            .onAppear {
                lgo.showingLogin = true
            }
            .navigationViewStyle(.columns)
            
            
            
            if !lgo.isLoggedIn {
                Text("")
                    .sheet(isPresented: $lgo.showingLogin) {
                        LoginSheetView()
                    }
            }
            
        }
    }
}
