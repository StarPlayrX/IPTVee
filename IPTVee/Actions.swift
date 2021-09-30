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
        print(categories)
        guard let categories = categories else {
            print("HELLO")
            LoginObservable.lgo.status = "Categories Error"
            print(LoginObservable.lgo.status)
            setCurrentStep = .CategoriesError
            awaitDone = false
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
        print(config)

        guard let config = config else {
            print("HELLO2")

            LoginObservable.lgo.status = "Configuration Error"
            print(LoginObservable.lgo.status)
            setCurrentStep = .ConfigurationError
            awaitDone = false
            return
        }
        
        conf = try? decoder.decode(Configuration.self, from: config)
        awaitDone = true
    }
}

