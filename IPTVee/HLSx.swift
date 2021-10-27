//
//  HLSx.swift
//  IPTVee
//
//  Created by M1 on 10/24/21.
//


import Foundation
import iptvKit
import Swifter

var hlsxPort: UInt16 = 1010

class HLSxServe {
    static let shared = HLSxServe()
    
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
    \(hlsx)://\(todd):\(boss)/\(live)\(good)/\(time)/\(xtrm)\(code)
    """
        
        guard
            let m3u8 = playlist.data(using: .utf8)
        else {
            return HttpResponse.ok(.text(playlist))
        }

        return HttpResponse.ok(.data(m3u8, contentType: "application/x-mpegURL"))
    }

    func stop_HLSx() {
        print("Stopping HLSx Protocol")
        self.hlsx.stop()
    }
    
    func start_HLSx() {
        print("Starting HLSx Protocol")

        hlsx["/:streamid/local.m3u8"] = { request in
            guard let streamid = request.params[":streamid"] else { return HttpResponse.ok(.data(Data(), contentType: "")) }
            return self.playlist(streamid: streamid)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var portOpen = false
            
            hlsxPort = UInt16.random(in: 1011...9998)

            while !portOpen {
                portOpen = self.isPortOpen(port: hlsxPort)
                hlsxPort = UInt16.random(in: 1012...9997)
            }
            
            print( "HLSx protocol starting on port: \(hlsxPort)")
            try? self.hlsx.start(hlsxPort, forceIPv4: true)
        }
    }
    
    func isPortOpen(port: in_port_t) -> Bool {

        let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        if socketFileDescriptor == -1 {
            return false
        }

        var addr = sockaddr_in()
        let sizeOfSockkAddr = MemoryLayout<sockaddr_in>.size
        addr.sin_len = __uint8_t(sizeOfSockkAddr)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
        addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        var bind_addr = sockaddr()
        memcpy(&bind_addr, &addr, Int(sizeOfSockkAddr))

        if Darwin.bind(socketFileDescriptor, &bind_addr, socklen_t(sizeOfSockkAddr)) == -1 {
            return false
        }
        if listen(socketFileDescriptor, SOMAXCONN ) == -1 {
            return false
        }
        return true
    }
}
