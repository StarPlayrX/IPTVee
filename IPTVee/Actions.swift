//
//  Actions.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import Foundation
import iptvKit

func getCategories() {
    let action = Actions.getLiveCategoriesAction.rawValue
    let endpoint = api.getEndpoint(creds, iptv, action)
        
    rest.getRequest(endpoint: endpoint) {  (categories) in
        guard let categories = categories else {
            LoginObservable.shared.status = "Get Categories Error"
            print(LoginObservable.shared.status)
            setCurrentStep = .CategoriesError
            awaitDone = false
            return
        }
        
        
        if let catz = try? decoder.decode(Categories.self, from: categories) {
            cats = catz
            for (i,cat) in catz.enumerated() {
                
                let nam = cat.categoryName.components(separatedBy: " ")
                print(nam)
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
                
                print(catName)
                
                
            }
            
        }
        
        
        
        print(cats)

       
      
        
        awaitDone = true
    }
}

func getConfig() {
    let action = Actions.configAction.rawValue
    let endpoint = api.getEndpoint(creds, iptv, action)
    
    rest.getRequest(endpoint: endpoint) { (config) in

        guard let config = config else {

            LoginObservable.shared.status = "Get Configuration Error"
            print(LoginObservable.shared.status)
            setCurrentStep = .ConfigurationError
            awaitDone = false
            return
        }
        
        conf = try? decoder.decode(Configuration.self, from: config)
        awaitDone = true
    }
}

func getChannels() {
    let action = Actions.getLiveStreams.rawValue
    let endpoint = api.getEndpoint(creds, iptv, action)
    
    rest.getRequest(endpoint: endpoint) { (config) in

        guard let config = config else {

            LoginObservable.shared.status = "Get Live Streams Error"
            print(LoginObservable.shared.status)
            setCurrentStep = .ConfigurationError
            awaitDone = false
            return
        }
        
        chan = try? decoder.decode(Channels.self, from: config)
        print(chan)
        awaitDone = true
    }
}

