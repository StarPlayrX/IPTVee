//  CategoriesView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/28/21.
//

import SwiftUI
import iptvKit



struct CategoriesView: View {
    @ObservedObject var lgo = LoginObservable.shared
    
    var body: some View {
        
        Group {
            Text("")
                .sheet(isPresented: $lgo.showingLogin) {
                    LoginSheetView()
                }
        
        CommonView()

            .onAppear {
                if !lgo.isLoggedIn {
                    lgo.showingLogin = true
                }
            }

            .navigationViewStyle( .columns )
        }
 
    }
}
