//
//  HLSx.swift
//  IPTVee
//
//  Created by M1 on 10/24/21.
//


import Foundation
import iptvKit
import Swifter

var hlsxPort = UInt16.random(in: 6666...7777)
let hlsx = HttpServer()

fileprivate func playlist(streamid: String) -> HttpResponse {
    
    let login = LoginObservable.shared
    let good = login.username
    let time = login.password
    let todd: String = login.config?.serverInfo.url ?? "primestreams.tv"
    let boss: String = login.config?.serverInfo.port ?? "826"
    let hlsx: String = "http"
    let code: String = ".ts"
    let live: String = "live"
    let xtrm: String = streamid
    
    let playlist =
"""
#EXTM3U
#EXTINF: -1, HLSx Protocol by IPTVee (c) 2021 Todd Goodtime Boss
\(hlsx)://\(todd):\(boss)/\(live)/\(good)/\(time)/\(xtrm)\(code)
"""
    
    guard
        let m3u8 = playlist.data(using: .utf8)
    else {
        return HttpResponse.ok(.text(playlist))
    }

    return HttpResponse.ok(.data(m3u8, contentType: "application/x-mpegURL"))
}


func hlsX() {
    hlsx["/:streamid/playlist.m3u8"] = { request in
        guard let streamid = request.params[":streamid"] else { return HttpResponse.ok(.data(Data(), contentType: "")) }
        return playlist(streamid: streamid)
    }

    DispatchQueue.global(qos: .userInitiated).async {
        do {
            try? hlsx.start(hlsxPort, forceIPv4: true)
            try print( "HLSx streaming protocol starting on port: \(hlsx.port())")
        } catch {
            print("HLSx streaming protocol error: \(error)")
        }
    }
}


