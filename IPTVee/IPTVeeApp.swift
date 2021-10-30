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
    @ObservedObject var lo = LoginObservable.shared
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
                
            
            Text("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarTitle("IPTVee")
                .onAppear()
                .onReceive(epgTimer) { _ in
                    if plo.videoController.player?.rate == 1 {
                        let min = Int(Calendar.current.component(.minute, from: Date()))
                        min % 6 == 0 || min % 6 == 3 ? getShortEpg(streamId: plo.streamID, channelName: plo.channelName, imageURL: plo.imageURL) : ()
                        min % 6 == 0 || min % 6 == 3 ? getNowPlayingEpg() : ()
                    } else {
                        let min = Calendar.current.component(.minute, from: Date())
                        min % 6 == 0 || min % 6 == 3 ? getNowPlayingEpg() : ()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    HLSxServe.shared.stop_HLSx()
                    savePlayerSettings()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    HLSxServe.shared.start_HLSx()
                    readPlayerSettings()

                }
                .onReceive(NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)) { info in
                    let airplayNow = avSession.currentRoute.outputs.first?.portType == .airPlay || plo.videoController.player!.isExternalPlaybackActive
                    if airplayNow {
                        
                        let good: String = lo.username
                        let time: String = lo.password
                        let todd: String = lo.config?.serverInfo.url ?? "primestreams.tv"
                        let boss: String = lo.config?.serverInfo.port ?? "826"
                        
                        plo.nowPlayingUrl = "Ternary, streamId: \(plo.streamID), port \(boss)"

                        guard let airplayUrl = URL(string:"http://\(todd):\(boss)/live/\(good)/\(time)/\(plo.streamID).m3u8") else { return }

                        let options = [AVURLAssetPreferPreciseDurationAndTimingKey : true, AVURLAssetAllowsCellularAccessKey : true, AVURLAssetAllowsExpensiveNetworkAccessKey : true, AVURLAssetAllowsConstrainedNetworkAccessKey : true, AVURLAssetReferenceRestrictionsKey: true ]
                        let asset = AVURLAsset.init(url: airplayUrl, options:options)
                        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
                        plo.videoController.player?.replaceCurrentItem(with: playerItem)
                        plo.videoController.player?.playImmediately(atRate: 1.0)
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
        runAVSession()
        HLSxServe.shared.start_HLSx()
        return true
    }
    
    static var interfaceMask = UIDevice.current.userInterfaceIdiom == .phone ? UIInterfaceOrientationMask.portrait : UIInterfaceOrientationMask.landscape
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.interfaceMask
    }
}

