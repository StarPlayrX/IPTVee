//
//  IPTVeeApp.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import SwiftUI
import AVFoundation
import iptvKit

@main
struct IPTVapp: App {
@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

let userSettings = "userSettings"

func saveUserDefaults() {
    UserDefaults.standard.set(try? PropertyListEncoder().encode(LoginObservable.shared.config), forKey:userSettings)
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
    
    fileprivate func setupVideoController(_ plo: PlayerObservable) {
        plo.videoController.player = AVPlayer()
        plo.videoController.player?.replaceCurrentItem(with: nil)
        plo.videoController.player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        plo.videoController.player?.automaticallyWaitsToMinimizeStalling = true
        plo.videoController.player?.appliesMediaSelectionCriteriaAutomatically = false
        plo.videoController.player?.preventsDisplaySleepDuringVideoPlayback = true
        plo.videoController.player?.allowsExternalPlayback = false
        plo.videoController.player?.usesExternalPlaybackWhileExternalScreenIsActive = true
        plo.videoController.player?.externalPlaybackVideoGravity = .resizeAspectFill
        plo.videoController.player?.actionAtItemEnd = .pause
    
        plo.videoController.requiresLinearPlayback = false
        plo.videoController.showsTimecodes = false
        plo.videoController.showsPlaybackControls = true
        plo.videoController.requiresLinearPlayback = false
        plo.videoController.canStartPictureInPictureAutomaticallyFromInline = true
        plo.videoController.entersFullScreenWhenPlaybackBegins = false
        plo.videoController.showsPlaybackControls = true
        plo.videoController.updatesNowPlayingInfoCenter = false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        avSession()
        setupVideoController(PlayerObservable.plo)
        application.beginReceivingRemoteControlEvents()
        loadUserDefaults()
        return true
    }
    

    static var interfaceMask = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.interfaceMask
    }
}



