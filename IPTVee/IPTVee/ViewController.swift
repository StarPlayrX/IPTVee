//
//  ViewController.swift
//  IPTVee
//
//  Created by M1 on 9/25/21.
//

import UIKit
import iptvKit

class ViewController: UIViewController {
    
    
    func getCategories(_ api: Api, _ creds: Creds, _ iptv: IPTV, _ rest: Rest) async {
        let getCats = Actions.getLiveCategoriesAction.rawValue
        let endpoint = api.getEndpoint(creds, iptv, getCats)
        
        rest.getRequest(endpoint: endpoint) { (categories) in
            guard let categories = categories else {
                return
            }
            
            let decoder = JSONDecoder()
            let cats = try? decoder.decode(Categories.self, from: categories)
            print(cats)
        }
    }
    
    func getConfig(_ api: Api, _ creds: Creds, _ iptv: IPTV, _ rest: Rest) {
        let getCats = Actions.configAction.rawValue
        let endpoint = api.getEndpoint(creds, iptv, getCats)
        
        rest.getRequest(endpoint: endpoint) { (categories) in
            guard let categories = categories else {
                return
            }
            
            let decoder = JSONDecoder()
            let config = try? decoder.decode(Configuration.self, from: categories)
            print(config)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let api = Api()

        let creds = Creds(
            username: "toddbruss90",
            password: "zzeH7C0xdw"
        )
        
        let iptv = IPTV(
            scheme: "https",
            host: "primestreams.tv",
            path: "/player_api.php",
            port: 29971)
        
        let rest = Rest()

        getConfig(api, creds, iptv, rest)
        getCategories(api, creds, iptv, rest)
    }
}

