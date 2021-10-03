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

let audioSession = AVAudioSession.sharedInstance()


class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Get the singleton instance.
        do {
            // Set the audio session category, mode, and options.
            try audioSession.setCategory(.playAndRecord, mode: .moviePlayback, options: [.allowBluetooth, .allowAirPlay, .defaultToSpeaker])
            try audioSession.setActive(true)
            

        } catch {
            print("Failed to set audio session category.")
        }
        
   
        // Other post-launch configuration.
        return true
        
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
