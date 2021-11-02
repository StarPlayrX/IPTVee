//
//  IPTVeeApp.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import SwiftUI
import AVFoundation
import iptvKit
import MediaPlayer

@main
struct IPTVapp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let epgTimer = Timer.publish(every: 60, on: .current, in: .default).autoconnect()
    @ObservedObject var plo = PlayerObservable.plo
    @ObservedObject var lgo = LoginObservable.shared
    
    var body: some Scene {
        
        WindowGroup {
                CategoriesView()
        }
    }
}

func loadUserDefaults() {
    if let data = UserDefaults.standard.value(forKey:userSettings) as? Data,
       let disk = try? PropertyListDecoder().decode(Config.self, from: data) {
        LoginObservable.shared.config = disk
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        startupAVPlayer()
        application.beginReceivingRemoteControlEvents()
        loadUserDefaults()
        runAVSession()
        HLSxServe.shared.start_HLSx()
        return true
    }

}

