//
//  ViewController.swift
//  IPTVee
//
//  Created by M1 on 9/25/21.
//

import UIKit
import iptvKit

class ViewController: UIViewController {
    
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
    let decoder = JSONDecoder()

    var cats: Categories? = nil
    var conf: Configuration? = nil

    func getCategories() {
        let getCats = Actions.getLiveCategoriesAction.rawValue
        let endpoint = api.getEndpoint(creds, iptv, getCats)
        
        rest.getRequest(endpoint: endpoint) {  (categories) in
            guard let categories = categories else { return }
            self.cats = try? self.decoder.decode(Categories.self, from: categories)
            print(self.cats)
        }
    }
    
    func getConfig() {
        let getConfig = Actions.configAction.rawValue
        let endpoint = api.getEndpoint(creds, iptv, getConfig)
        
        rest.getRequest(endpoint: endpoint) { (config) in
            guard let config = config else { return }
            
            let decoder = JSONDecoder()
            self.conf = try? decoder.decode(Configuration.self, from: config)
            print(self.conf)
        }
    }
    
 
    
    @IBAction func Login(_ sender: Any) {
        getConfig()
        getCategories()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
