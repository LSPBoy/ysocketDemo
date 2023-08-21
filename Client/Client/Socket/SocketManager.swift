//
//  LSPSocket.swift
//  Client
//
//  Created by apple on 2023/8/17.
//

import Foundation

protocol SocketManagerDelegate: AnyObject {
    func socket(_ socketMgr: SocketManager, joinRoom: UserInfo)
    func socket(_ socketMgr: SocketManager, leaveRoom: UserInfo)
    func socket(_ socketMgr: SocketManager, chat: ChatMessage)
    func socket(_ socketMgr: SocketManager, giftMsg: GiftMessage)
}

class SocketManager {
    weak var delegate: SocketManagerDelegate?
    fileprivate var tcpClient: TCPClient
    fileprivate var userInfo: UserInfo = {
        var userInfo = UserInfo()
        userInfo.name = "张三\(arc4random_uniform(10))"
        userInfo.level = 20
        return userInfo
    }()
    
    init(addr: String, port: Int) {
        tcpClient = TCPClient(addr: addr, port: port)
    }
}

extension SocketManager {
    func connectServer() -> Bool {
        return tcpClient.connect(timeout: 5).0
    }
    
    func startReadMsg() {
        DispatchQueue.global().async {
            while true {
                guard let hMsg = self.tcpClient.read(4)  else {
                    continue
                }
                //1.读取消息长度的data
                let headerData = Data(bytes: hMsg, count: 4)
                var msgLength: Int = 0
                (headerData as NSData).getBytes(&msgLength, length: 4)
                print("消息长度===\(msgLength)")
                
                //2.读取消息类型的data
                guard let typeMsg = self.tcpClient.read(2) else { return }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                print("类型====\(type)")
                
                //2.根据长度读取真实消息
                guard let msg = self.tcpClient.read(msgLength) else {
                    return
                }
                let msgData = Data(bytes: msg, count: msgLength)
                
                //3. 根据类型处理消息
                DispatchQueue.main.async {
                    self.handleMsg(type: type, msgData: msgData)
                }
            }
        }
    }
}


extension SocketManager {
    fileprivate func handleMsg(type: Int, msgData: Data) {
        switch type {
        case 0:
            do {
                let user = try UserInfo(serializedData: msgData)
                print("加入房间name==\(user.name), level==\(user.level)")
                delegate?.socket(self, joinRoom: user)
            } catch {}
        case 1:
            do {
                let user = try UserInfo(serializedData: msgData)
                print("离开房间name==\(user.name), level==\(user.level)")
                delegate?.socket(self, leaveRoom: user)
            } catch {}
        case 2:
            do {
                let chatMsg = try ChatMessage(serializedData: msgData)
                print("文本消息===\(chatMsg.text)")
                delegate?.socket(self, chat: chatMsg)
            } catch {}
        case 3:
            do {
                let giftMsg = try GiftMessage(serializedData: msgData)
                print("礼物消息===\(giftMsg.giftname)")
                delegate?.socket(self, giftMsg: giftMsg)
            } catch {}
           
        default:
            print("未知消息类型")
        }
    }
}

extension SocketManager {
    //type0
    func sendJoinRoomMsg() {
        do {
            let data: Data = try userInfo.serializedData()
            sendMsg(data: data, type: 0)
        } catch {
            print("错误")
        }
    }
    
    //type1
    func sendLeaveRoomMsg() {
        do {
            let data: Data = try userInfo.serializedData()
            sendMsg(data: data, type: 1)
        } catch {
            print("错误")
        }
    }
    
    //type2
    func sendTextMsg(message: String) {
        var chatMsg = ChatMessage()
        chatMsg.text = message
        chatMsg.user = userInfo
        do {
          let chatData = try chatMsg.serializedData()
          sendMsg(data: chatData, type: 2)
        } catch {}
    }
    
    //type3
    func sendGiftMsg(giftName: String, giftURL: String, giftCount: Int) {
        var giftMsg = GiftMessage()
        giftMsg.user = userInfo
        giftMsg.giftname = giftName
        giftMsg.giftURL = giftURL
        giftMsg.giftcount = Int32(giftCount)
        do {
          let giftData = try giftMsg.serializedData()
          sendMsg(data: giftData, type: 3)
        } catch {}
    }
    
    //type100
    func sendHeartBeat() {
        //1.获取心跳包的数据
        let heartString = "I am is heart beat;"
        guard let heartData = heartString.data(using: .utf8) else {
            return
        }

        //2.发送心跳包，约定type是100
        sendMsg(data: heartData, type: 100)
    }
    
    private func sendMsg(data: Data, type: Int) {
        var length = data.count
        
        //2.将消息长度，写入到data
        let headerData = Data(bytes: &length, count: 4)
        
        
        //3.消息类型
        var tempType = type
        let typeData = Data(bytes: &tempType, count: 2)
        
        //3.发消息
        let totalData = headerData + typeData + data
        
        tcpClient.send(data: totalData)
    }
}
