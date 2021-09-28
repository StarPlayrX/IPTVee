//
//  Actions.swift
//  IPTVee
//
//  Created by M1 on 9/27/21.
//

import Foundation
import iptvKit

func login(_ user: String,_ pass: String,_ host: String,_ port: String) {
    awaitDone = false
    
    guard let port = Int(port) else { return }
    creds.username = user
    creds.password = pass
    iptv.host = host
    iptv.port = port
    
    getConfig()
    Async().await(action: Actions.getLiveCategoriesAction.rawValue)
}

func getCategories() {
    let getCats = Actions.getLiveCategoriesAction.rawValue
    let endpoint = api.getEndpoint(creds, iptv, getCats)
        
    rest.getRequest(endpoint: endpoint) {  (categories) in
        guard let categories = categories else {
            awaitDone = true
            return
        }
        cats = try? decoder.decode(Categories.self, from: categories)
        awaitDone = true
    }
}

func getConfig() {
    let getConfig = Actions.configAction.rawValue
    let endpoint = api.getEndpoint(creds, iptv, getConfig)
    
    rest.getRequest(endpoint: endpoint) { (config) in

        guard let config = config else {
            awaitDone = true
            return
        }
        
        conf = try? decoder.decode(Configuration.self, from: config)
        awaitDone = true
    }
}

