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
                self.await = true
                return
            }
            self.cats = try? self.decoder.decode(Categories.self, from: categories)
            self.await = true
        }
    }
    
    func getConfig() {
        let getConfig = Actions.configAction.rawValue
        let endpoint = api.getEndpoint(creds, iptv, getConfig)
        
        rest.getRequest(endpoint: endpoint) { (config) in

            guard let config = config else {
                self.await = true
                return
            }
            
            self.conf = try? self.decoder.decode(Configuration.self, from: config)
            self.await = true
        }
    }
    
    var await = false
    
    func async(action: String) {
        DispatchQueue.global().async { [unowned self] in
            while !self.await {}
            if action == Actions.getLiveCategoriesAction.rawValue {
                print("1")
                print(self.conf as Any)
                getCategories()
                self.await = false
                async(action: "")
            } else if action.isEmpty {
                print("2")
                print(self.cats as Any)
            }
        }
    }
    
    @IBAction func Login(_ sender: Any) {
        self.await = false
        getConfig()
        async(action: Actions.getLiveCategoriesAction.rawValue)

    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
