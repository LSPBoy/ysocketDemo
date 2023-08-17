//
//  LSPSocket.swift
//  Client
//
//  Created by apple on 2023/8/17.
//

import Foundation

class SocketManager {
    fileprivate var tcpClitent: TCPClient
    
    init(addr: String, port: Int) {
        tcpClitent = TCPClient(addr: addr, port: port)
    }
}

extension SocketManager {
    func connectServer() -> Bool {
        return tcpClitent.connect(timeout: 5).0
    }
    
    func sendData(_ data: Data) {
        tcpClitent.send(data: data)
    }
}
