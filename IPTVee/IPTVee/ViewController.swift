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
            guard let categories = categories else {
                self.asyncRan = true
                return
            }
            self.cats = try? self.decoder.decode(Categories.self, from: categories)
            self.asyncRan = true
        }
    }
    
    func getConfig() {
        let getConfig = Actions.configAction.rawValue
        let endpoint = api.getEndpoint(creds, iptv, getConfig)
        
        rest.getRequest(endpoint: endpoint) { (config) in

            guard let config = config else {
                self.asyncRan = true
                return
            }
            
            self.conf = try? self.decoder.decode(Configuration.self, from: config)
            self.asyncRan = true
        }
    }
    
    var asyncRan = false
    
    func awaitRan(action: String) {
        DispatchQueue.global().async { [unowned self] in
            while !self.asyncRan {}
            if action == Actions.getLiveCategoriesAction.rawValue {
                print("1")
                print(self.conf as Any)
                getCategories()
                asyncRan = false
                awaitRan(action: "")
            } else if action.isEmpty {
                print("2")
                print(self.cats as Any)
            }
        }
    }
    
    @IBAction func Login(_ sender: Any) {
        asyncRan = false
        getConfig()
        awaitRan(action: Actions.getLiveCategoriesAction.rawValue)

    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
