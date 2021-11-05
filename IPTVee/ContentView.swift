//  ContentView.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/28/21.
//
import SwiftUI
import iptvKit

struct ContentView: View {
    @ObservedObject var lgo = LoginObservable.shared
    
    var body: some View {
        
        Group {
            Text("")
                .sheet(isPresented: $lgo.showingLogin) {
                    LoginSheetView()
                }
        CategoriesView()
            .onAppear {
                if !lgo.isLoggedIn {
                    lgo.showingLogin = true
                }
            }
            .navigationViewStyle( .columns )
        }
    }
}
