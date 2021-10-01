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
    
    var body: some View {
            Form {
                Section(header: Text("CATEGORIES")) {
                    ForEach(Array(cats),id: \.categoryName) { cat in
                        Text(cat.categoryName)
                    }
                }.navigationTitle("IPTVee")
                
            }

    }
}
