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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationBarTitleDisplayMode(.inline)

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
    
    func avSession() {
        let avSession = AVAudioSession.sharedInstance()
        
        do {
            avSession.accessibilityPerformMagicTap()
            avSession.accessibilityActivate()
            try avSession.setPreferredIOBufferDuration(0)
            try avSession.setCategory(.playback, mode: .moviePlayback, policy: .longFormVideo, options: [])
            try avSession.setActive(true)
        } catch {
            print(error)
        }
    }
  
    

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        avSession()
        setupVideoController(PlayerObservable.plo)
        application.beginReceivingRemoteControlEvents()
        loadUserDefaults()
        return true
    }

    static var interfaceMask = UIDevice.current.userInterfaceIdiom == .phone ? UIInterfaceOrientationMask.portrait : UIInterfaceOrientationMask.landscape
  
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.interfaceMask
    }
}
