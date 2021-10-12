//
//  Actions.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import Foundation
import iptvKit
import MediaPlayer

func getCategories() {
    let action = Actions.getLiveCategoriesAction.rawValue
    let endpoint = api.getEndpoint(creds, iptv, action)
    
    rest.getRequest(endpoint: endpoint) {  (categories) in
        guard let categories = categories else {
            LoginObservable.shared.status = "Get Categories Error"
            setCurrentStep = .CategoriesError
            awaitDone = false
            return
        }
        
        if let catz = try? decoder.decode(Categories.self, from: categories) {
            cats = catz
            for (i,cat) in catz.enumerated() {
                
                let nam = cat.categoryName.components(separatedBy: " ")
                var catName = ""
                
                for x in nam {
                    if x.count > 5 {
                        catName.append(contentsOf: x.localizedCapitalized)
                    } else {
                        catName.append(contentsOf: x)
                    }
                    
                    catName += " "
                }
                
                cats[i].categoryName = catName
                cats[i].categoryName.removeLast()
                
            }
        }
        
        if cats.count > 3 { cats.removeLast() }
        
        awaitDone = true
    }
}

func getConfig() {
    let action = Actions.configAction.rawValue
    let endpoint = api.getEndpoint(creds, iptv, action)
    
    func loginError() {
        LoginObservable.shared.status = "Login Error"
        setCurrentStep = .ConfigurationError
        awaitDone = false
    }
    
    rest.getRequest(endpoint: endpoint) { (login) in
        guard let login = login else {
            loginError()
            return
        }
        
        if let config = try? decoder.decode(Configuration.self, from: login) {
            LoginObservable.shared.config = config
            saveUserDefaults()
        } else {
            loginError()
        }
        
        awaitDone = true
    }
}

func getChannels() {
    let action = Actions.getLiveStreams.rawValue
    let endpoint = api.getEndpoint(creds, iptv, action)
    
    rest.getRequest(endpoint: endpoint) { (config) in
        
        guard let config = config else {
            
            LoginObservable.shared.status = "Get Live Streams Error"
            setCurrentStep = .ConfigurationError
            awaitDone = false
            return
        }
        
        if let channels = try? decoder.decode(Channels.self, from: config) {
            chan = channels
        }
        
        awaitDone = true
    }
}

func getShortEpg(streamId: String, channelName: String, imageURL: String) {
    let action = Actions.getshortEpg.rawValue
    let endpoint = api.getEpgEndpoint(creds, iptv, action, streamId)
    
    rest.getRequest(endpoint: endpoint) { (programguide) in
        guard let programguide = programguide else {
            LoginObservable.shared.status = "Get Short EPG Error"
            return
        }
        
        if let epg = try? decoder.decode(ShortIPTVEpg.self, from: programguide) {
            shortEpg = epg
            PlayerObservable.plo.miniEpg = shortEpg?.epgListings ?? []
            
            DispatchQueue.global().async {
                if let url = URL(string: imageURL) {
                    let data = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
                        
                        if let data = data, let image = UIImage(data: data) {
                            setnowPlayingInfo(channelName: channelName, image: image)
                        } else {
                            setnowPlayingInfo(channelName: channelName, image: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    
}






func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
    
    UIGraphicsBeginImageContextWithOptions( targetSize, false, 1.0)
    
    image.draw(in: rect)
    
    if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
        UIGraphicsEndImageContext()
        return newImage
    }
    
    return UIImage()
}


func setnowPlayingInfo(channelName:String, image: UIImage?) {
    let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
    
    if let image = image {
        
      

        let img = image.squareMe()

        let artwork = MPMediaItemArtwork(boundsSize: img.size, requestHandler: {  (_) -> UIImage in
            return img
        })
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
    } else {
        nowPlayingInfo[MPMediaItemPropertyArtwork] = nil

    }
   
    let title = PlayerObservable.plo.miniEpg.first?.title.base64Decoded ?? "IPTvee"
    nowPlayingInfo[MPMediaItemPropertyTitle] = channelName
    nowPlayingInfo[MPMediaItemPropertyArtist] = title
    nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "IPTVee"
    nowPlayingInfo[MPMediaItemPropertyMediaType] = 1
    nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
    nowPlayingInfo[MPMediaItemPropertyAlbumTitle] =  PlayerObservable.plo.miniEpg.first?.start.toDate()?.toString()
    nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
    nowPlayingInfoCenter.playbackState = PlayerObservable.plo.videoController.player?.rate == 1 ? .playing : .unknown
    nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    
}



func loopOverChannelsNowPlaying() {
    
}

/*
 
 
 
 
 */
