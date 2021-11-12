//
//  IPTVeeApp.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import SwiftUI
import AVFoundation
import iptvKit
import UIKit

@main
struct IPTVapp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.colorScheme) var colorScheme
    
    let epgTimer = Timer.publish(every: 60, on: .current, in: .default).autoconnect()
    @ObservedObject var plo = PlayerObservable.plo
    @ObservedObject var lgo = LoginObservable.shared
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    let calendar = Calendar.current
    
    var body: some Scene {
        WindowGroup {
            Group {
                ContentView()
            }
            .statusBar(hidden: isPad)
            .onReceive(epgTimer) { date in
                let minute = calendar.component(.minute, from: date)
                
                if minute == 0 || minute == 15 || minute == 30 || minute == 45 {
                    DispatchQueue.main.async {
                        getShortEpg(streamId: plo.streamID, channelName: plo.channelName, imageURL: plo.imageURL)
                        getNowPlayingEpg()
                    }
                }
            }
            .padding(.top, -5)
            .edgesIgnoringSafeArea(.all)
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
