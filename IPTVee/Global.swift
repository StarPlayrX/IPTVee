//
//  Global.swift
//  IPTVee
//
//  Created by M1 on 9/27/21.
//

import Foundation
import iptvKit

let api = Api()

var creds = Creds(
    username: "toddbruss90",
    password: "zzeH7C0xdw"
)

var iptv = IPTV(
    scheme: "http",
    host: "",
    path: "/player_api.php",
    port: 80) //29971

let rest = Rest()
let decoder = JSONDecoder()

var cats: Categories? = nil
var conf: Configuration? = nil



class Status: ObservableObject {
    static var status = Status()
    @Published var success: String = "test"
}
