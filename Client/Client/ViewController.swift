//
//  ViewController.swift
//  Client
//
//  Created by apple on 2023/8/17.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var hintLabel: UILabel!
    
    fileprivate lazy var socketMgr: SocketManager = SocketManager(addr: "127.0.0.1", port: 7878)
    @IBOutlet weak var inputField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hintLabel.isHidden = true
    }

    @IBAction func connnectServer(_ sender: Any) {
        hintLabel.isHidden = false
        if socketMgr.connectServer() {
            hintLabel.text = "连接上了服务器"
            hintLabel.textColor = .green
            socketMgr.startReadMsg()
        } else {
            hintLabel.text = "连接失败"
            hintLabel.textColor = .red
        }
    }
    
    @IBAction func sendMsg(_ sender: Any) {
        guard let message = inputField.text else { return }
        socketMgr.sendTextMsg(message: message)
    }
    
    @IBAction func joinRoom(_ sender: Any) {
        socketMgr.sendJoinRoomMsg()
    }
    
    @IBAction func leaveRoom(_ sender: Any) {
        socketMgr.sendLeaveRoomMsg()
    }
    
    @IBAction func sendGift(_ sender: Any) {
        socketMgr.sendGiftMsg(giftName: "嘉年华", giftURL: "https:www.baidu.com", giftCount: 10)
    }
}

extension ViewController {
   
}
