//
//  CategoriesView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/28/21.
//

import Foundation
import SwiftUI

class CategoriesObservable: ObservableObject {
    static var cto = CategoriesObservable()
    @Published var status: String = "test"
    @Published var loggedIn: Bool = false
}

struct CategoriesView: View {
    @ObservedObject var obs = LoginObservable.shared

    var body: some View {

            Form {
                Section(header: Text("CATEGORIES")) {
                    
                    ForEach(Array(cats),id: \.categoryName) { cat in
                        
                        HStack {
                            NavigationLink(cat.categoryName,destination: ChannelsView(categoryID: cat.categoryID))
                                .foregroundColor(.white)
                        }
                    }
                }.navigationTitle("Categories")
                
            }.onAppear(perform: { AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait })
    }
}
