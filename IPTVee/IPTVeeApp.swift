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
    
    var body: some Scene {
        
        
        WindowGroup {
            
            Group {
                ContentView()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarTitle("IPTVee")
                    .onAppear()
                    .onReceive(epgTimer) { _ in
                        if plo.videoController.player?.rate == 1 {
                            let min = Int(Calendar.current.component(.minute, from: Date()))
                            min % 6 == 0 || min % 6 == 3 ? getShortEpg(streamId: plo.streamID, channelName: plo.channelName, imageURL: plo.imageURL) : ()
                            min % 6 == 0 || min % 6 == 3 ? getNowPlayingEpg(channelz: ChannelsObservable.shared.chan) : ()
                        } else {
                            let min = Calendar.current.component(.minute, from: Date())
                            min % 6 == 0 || min % 6 == 3 ? getNowPlayingEpg(channelz: ChannelsObservable.shared.chan) : ()
                        }
                    }
            }
            
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
        setupVideoController(PlayerObservable.plo)
        application.beginReceivingRemoteControlEvents()
        loadUserDefaults()
        
        HLSxServe.shared.start_HLSx()
        return true
    }
    
    static var interfaceMask = UIDevice.current.userInterfaceIdiom == .phone ? UIInterfaceOrientationMask.portrait : UIInterfaceOrientationMask.landscape
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.interfaceMask
    }
}
