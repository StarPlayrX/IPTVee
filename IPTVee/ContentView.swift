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
            
            if isPhone {
                CategoriesView()
                    .onAppear {
                        if !lgo.isLoggedIn {
                            lgo.showingLogin = true
                        }
                    }
                    .navigationViewStyle( .stack )
            } else {
                CategoriesView()
                    .onAppear {
                        if !lgo.isLoggedIn {
                            lgo.showingLogin = true
                        }
                    }
                    .padding([.top], isPad ? -5 : 0)
                    .navigationViewStyle( .columns )
            }
        }
        .statusBar(hidden: isPad)

    }
}
