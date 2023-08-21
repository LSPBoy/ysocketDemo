//
//  ClientManager.swift
//  Server
//
//  Created by apple on 2023/8/17.
//

import UIKit

protocol ClientManagerDelegate: AnyObject {
    func sendMsgToClient(_ data: Data)
    func removeClient(_ client: ClientManager)
}

class ClientManager: NSObject {
    var tcpClient: TCPClient
    weak var delegate: ClientManagerDelegate?
    fileprivate var isClientConnected: Bool = false
    
    fileprivate var heartTimeCount : Int = 0
    
    fileprivate var timer: Timer?
    
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }
}

extension ClientManager {
    
    func startReadMsg() {
        isClientConnected = true
        
        timer = Timer(fireAt: Date(), interval: 1, target: self, selector: #selector(checkHeartBeat), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
        timer!.fire()
        
        //4是和服务器约定，前面4个保存的是消息总长度
        while isClientConnected {
   
            if let hMsg = tcpClient.read(4) {
                //1.读取消息长度的data
                let headerData = Data(bytes: hMsg, count: 4)
                var msgLength: Int = 0
                (headerData as NSData).getBytes(&msgLength, length: 4)
                print("消息长度===\(msgLength)")
                
                //2.读取消息类型的data
                guard let typeMsg = tcpClient.read(2) else { return }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                print("类型====\(type)")
                
                //2.根据长度读取真实消息
                guard let msg = tcpClient.read(msgLength) else {
                    return
                }
                let msgData = Data(bytes: msg, count: msgLength)
                print("type===\(type)")
                if type == 1 {//退出房间
                    tcpClient.close()
                    delegate?.removeClient(self)
                } else if type == 100 {//约定type100是心跳包，心跳不用转发给其他人，所以continue
                    heartTimeCount = 0
                    continue
                }
                let message = String(data: msgData, encoding: .utf8)
                print("message===\(message ?? "")")
                let totalData = headerData + typeData + msgData
                delegate?.sendMsgToClient(totalData)
                
            } else {
                removeClient()
            }
        }
    }
}

extension ClientManager {
    
    private func removeClient() {
        print("客户端断开了连接")
        delegate?.removeClient(self)
        isClientConnected = false
        tcpClient.close()
        stopTimer()
    }
    
    
    private func stopTimer() {
        print("移除定时器")
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func checkHeartBeat() {
        heartTimeCount += 1
        if heartTimeCount >= 10 {
            self.removeClient()
        }
        print("检查心跳：\(heartTimeCount)");
    }
}
