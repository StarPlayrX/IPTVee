import SwiftUI
import AVKit
import iptvKit

struct PlayerView: View {
    
    @ObservedObject var plo = PlayerObservable.plo
    
    var isPortrait: Bool {
        guard let scene =  (UIApplication.shared.connectedScenes.first as? UIWindowScene) else {
            return true
        }
        
        return scene.interfaceOrientation.isPortrait
    }
    
    var body: some View {
        
      
        
        Group {
            GeometryReader { geometry in
                Form{}
                
                VStack {
                  
                    HStack {
                        AVPlayerView()
                            .frame(width: isPortrait ? geometry.size.width : .infinity, height: isPortrait ? geometry.size.width * 0.5625 : .infinity, alignment: .center)
                            .background(Color(UIColor.systemBackground))
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            if !isPortrait, let desc = plo.miniEpg.first?.title.base64Decoded, desc.count > 3 {
                                VStack {
                                    Text("\(plo.channelName)")
                                        .fontWeight(.bold)
                                    Text("\(desc)")
                                        .fontWeight(.regular)
                                }
                                .frame(alignment: .center)
                                .multilineTextAlignment(.center)
                                .frame(minWidth: 320, alignment: .center)
                                .font(.body)
                            }
                        }
                    }
                    
                    if isPortrait {
                        Form {
                            if !plo.miniEpg.isEmpty {
                                
                                Section(header: Text("PROGRAM GUIDE")) {
                                    ForEach(Array(plo.miniEpg),id: \.id) { epg in
                                        
                                        HStack {
                                            Text(epg.start.toDate()?.userTimeZone().toString() ?? "")
                                                .fontWeight(.medium)
                                                .frame(minWidth: 78, alignment: .trailing)
                                                .multilineTextAlignment(.leading)
                                            
                                            Text(epg.title.base64Decoded ?? "")
                                                .multilineTextAlignment(.leading)
                                                .padding(.leading, 5)
                                        }
                                        .font(.callout)
                                    }
                                }
                            }
                            
                            if let desc = plo.miniEpg.first?.epgListingDescription.base64Decoded, desc.count > 3 {
                                Section(header: Text("Description")) {
                                    Text(desc)
                                    //.font(.body)
                                    //.fontWeight(.light)
                                        .frame(minWidth: 80, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                }
                            } else {
                                Section(header: Text("Description")) {
                                    Text(plo.channelName)
                                        .font(.body)
                                        .fontWeight(.light)
                                        .frame(minWidth: 80, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(plo.channelName)
        
        
    }
    
    func performMagicTap() {
        plo.videoController.player?.rate == 1 ? plo.videoController.player?.pause() : plo.videoController.player?.play()
    }
    
    
    //Back burner
    func skipForward(_ videoController: AVPlayerViewController ) {
        let seekDuration: Double = 10
        videoController.player?.pause()
        
        guard
            let player = videoController.player
        else {
            return
        }
        
        var playerCurrentTime = CMTimeGetSeconds( player.currentTime() )
        playerCurrentTime += seekDuration
        
        let time: CMTime = CMTimeMake(value: Int64(playerCurrentTime * 1000 as Double), timescale: 1000)
        videoController.player?.seek(to: time)
        videoController.player?.play()
    }
    
    //Back burner
    func skipBackward(_ videoController: AVPlayerViewController ) {
        let seekDuration: Double = 10
        videoController.player?.pause()
        
        guard
            let player = videoController.player
        else {
            return
        }
        
        var playerCurrentTime = CMTimeGetSeconds( player.currentTime() )
        playerCurrentTime -= seekDuration
        
        let time: CMTime = CMTimeMake(value: Int64(playerCurrentTime * 1000 as Double), timescale: 1000)
        videoController.player?.seek(to: time)
        videoController.player?.play()
    }
}
