//
//  ClientManager.swift
//  Server
//
//  Created by apple on 2023/8/17.
//

import UIKit

class ClientManager {
    var tcpClient: TCPClient
    
    fileprivate var isClientConnected: Bool = false
    
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }
}

extension ClientManager {
    func startReadMsg() {
        isClientConnected = true
        //4是和服务器约定，前面4个保存的是消息总长度
        while isClientConnected {
            if let headData = tcpClient.read(4) {
                //1.读取消息长度的data
                let msgData = Data(bytes: headData, count: 4)
                var msgLength: Int = 0
                (msgData as NSData).getBytes(&msgLength, length: 4)
                print("消息长度===\(msgLength)")
                
                //2.读取消息类型的data
                guard let typeMsg = tcpClient.read(2) else { return }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                print("类型长度====\(type)")
                
                
                //2.根据长度读取真实消息
                guard let msg = tcpClient.read(msgLength) else {
                    return
                }
                let data = Data(bytes: msg, count: msgLength)
                let message = String(data: data, encoding: .utf8)
                print("msg===\(message ?? "xxx")")
            } else {
                isClientConnected = false
                print("客户端断开了连接")
            }
        }
    }
}
