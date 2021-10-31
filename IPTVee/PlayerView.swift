import SwiftUI
import AVKit

struct PlayerView: View {
   
    
    var isPortrait: Bool {
        guard let scene =  (UIApplication.shared.connectedScenes.first as? UIWindowScene) else {
            return true
        }
        
        return scene.interfaceOrientation.isPortrait
    }
    
 
    var body: some View {
        Text("HELLWORLD")
        GeometryReader { geometry in
            Form{}
            
            HStack {
                AVPlayerView()
                    .frame(width: isPortrait ? geometry.size.width : .infinity, height: isPortrait ? geometry.size.width * 0.5625 : .infinity, alignment: .center)
                    .background(Color(UIColor.systemBackground))
            }
        }
    }
}
