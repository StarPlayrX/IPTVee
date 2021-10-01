//
//  IPTVeeApp.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import SwiftUI

@main
struct IPTVeeApp: App {
    var body: some Scene {
        WindowGroup {
          ContentView(obs: LoginObservable.shared)
               
        }
    }
}
