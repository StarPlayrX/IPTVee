//
//  Actions.swift
//  IPTVee
//
//  Created by M1 on 9/27/21.
//

import Foundation
import iptvKit



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

