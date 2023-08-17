//
//  ViewController.swift
//  Client
//
//  Created by apple on 2023/8/17.
//

import UIKit

class ViewController: UIViewController {

    fileprivate lazy var socket: SocketManager = SocketManager(addr: "127.0.0.1", port: 7878)
    @IBOutlet weak var inputField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
    }

    @IBAction func connnectServer(_ sender: Any) {
        if socket.connectServer() {
            print("连接上了服务器")
        }
    }
    
    @IBAction func sendMsg(_ sender: Any) {
        if let message = inputField.text {
            //1.获取消息长度
            guard let data = message.data(using: .utf8) else {
                return
            }
            var length = data.count
            
            //2.将消息长度，写入到data
            let headerData = Data(bytes: &length, count: 4)
            
            
            //3.消息类型
            var type = 2
            let typeData = Data(bytes: &type, count: 2)
            
            //3.发消息
            let totalData = headerData + typeData + data
            socket.sendData(totalData)
        }
    }
    
}

