//
//  IPTVeeApp.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import SwiftUI
import AVFoundation

@main
struct IPTVapp: App {
@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let avSession = AVAudioSession.sharedInstance()

        // Get the singleton instance.
        do {
            // Set the audio session category, mode, and options.
            try avSession.setPreferredIOBufferDuration(0)
            try avSession.setCategory(.playback, mode: .moviePlayback, policy: .longFormVideo, options: [])
            try avSession.setActive(true)
            
        } catch {
            print(error.localizedDescription)
        }
        
        return true
    }
        
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}
