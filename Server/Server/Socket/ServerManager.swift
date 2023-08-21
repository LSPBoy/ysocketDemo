//
//  ServerManager.swift
//  Server
//
//  Created by apple on 2023/8/17.
//

import UIKit

class ServerManager {
    fileprivate lazy var serverSocket: TCPServer = TCPServer(addr: "0.0.0.0", port: 7878)
    fileprivate var isServerRunning: Bool = false
    fileprivate lazy var clientMgrs: [ClientManager] = [ClientManager]()
}

extension ServerManager {
    
    func startRunning() {
        //1.开启监听
        serverSocket.listen()
        isServerRunning = true
        
        //2.开始接收客户端
        DispatchQueue.global().async {
            while self.isServerRunning {
                if let client = self.serverSocket.accept() {
                    DispatchQueue.global().async {
                        print("接收到一个客户端的连接")
                        self.handleClient(client)
                    }
                }
            }
        }
    }
    
    func stopRunning() {
        isServerRunning = false
    }
    
}

extension ServerManager {
    fileprivate func handleClient(_ client: TCPClient) {
        //1.用一个ClientManager管理tcpClient
        let mgr = ClientManager(tcpClient: client)
        mgr.delegate = self
        //2.保存客户端
        clientMgrs.append(mgr)
        
        //3.用client开始接收消息
        mgr.startReadMsg()
    }
}

extension ServerManager: ClientManagerDelegate {
    func sendMsgToClient(_ data: Data) {
        for mgr in clientMgrs {
            mgr.tcpClient.send(data: data)
        }
    }
    
    func removeClient(_ client: ClientManager) {
        guard let index = clientMgrs.firstIndex(of: client) else { return }
        clientMgrs.remove(at: index)
    }
}
