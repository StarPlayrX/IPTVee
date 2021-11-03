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
import UIKit

@main
struct IPTVapp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.colorScheme) var colorScheme
    
    let epgTimer = Timer.publish(every: 60, on: .current, in: .default).autoconnect()
    @ObservedObject var plo = PlayerObservable.plo
    @ObservedObject var lgo = LoginObservable.shared
    
    var isMac: Bool {
        #if targetEnvironment(macCatalyst)
        true
        #else
        false
        #endif
    }
    
    let calendar = Calendar.current

    var body: some Scene {
        
        WindowGroup {
            
            Group {
                if colorScheme == .light {
                    CategoriesView()
                        .withHostingWindow { window in
                            #if targetEnvironment(macCatalyst)
                            if isMac, let titlebar = window?.windowScene?.titlebar {
                                titlebar.titleVisibility = .hidden
                                titlebar.toolbarStyle = .unified
                                titlebar.separatorStyle = .none
                                titlebar.toolbar = nil
                                window?.windowScene?.title = ""
                                
                            }
                            #endif
                        }
                        .padding(.top, isMac ? -45 : 0)
                        .background(Color(UIColor.secondarySystemBackground))
                } else {
                    CategoriesView()
                        .withHostingWindow { window in
                            #if targetEnvironment(macCatalyst)
                            if isMac, let titlebar = window?.windowScene?.titlebar {
                                titlebar.titleVisibility = .hidden
                                titlebar.toolbarStyle = .unified
                                titlebar.separatorStyle = .none
                                titlebar.toolbar = nil
                                window?.windowScene?.title = ""
                                
                            }
                            #endif
                        }
                        .padding(.top, isMac ? -45 : 0)
                }
            }.onReceive(epgTimer) { date in
                let minute = calendar.component(.minute, from: date)
                
                if minute == 0 || minute == 15 || minute == 30 || minute == 45 {
                    DispatchQueue.main.async {
                        getShortEpg(streamId: plo.streamID, channelName: plo.channelName, imageURL: plo.imageURL)
                        getNowPlayingEpg()
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
        startupAVPlayer()
        application.beginReceivingRemoteControlEvents()
        loadUserDefaults()
        runAVSession()
        HLSxServe.shared.start_HLSx()
        return true
    }
}

extension View {
    fileprivate func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

fileprivate struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
