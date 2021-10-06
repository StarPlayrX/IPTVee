//
//  Global.swift
//  IPTVee
//
//  Created by Todd Bruss on 9/27/21.
//

import Foundation
import iptvKit
import AVKit

let api = Api()

var creds = Creds (
    username: "toddbruss90",
    password: "zzeH7C0xdw"
)

var iptv = IPTV (
    scheme: "http",
    host: "",
    path: "/player_api.php",
    port: 80) //29971

let rest = Rest()
let decoder = JSONDecoder()

var cats: Categories = Categories()
var conf: Configuration? = nil
var chan: Channels = Channels()
