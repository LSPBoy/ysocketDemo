//
//  ViewController.swift
//  Server
//
//  Created by apple on 2023/8/17.
//

import UIKit

class ViewController: UIViewController {

    fileprivate lazy var serverMgr : ServerManager = ServerManager()
    @IBOutlet weak var hintLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hintLabel.isHidden = true
    }
    
    @IBAction func startServer(_ sender: Any) {
        serverMgr.startRunning()
        hintLabel.text = "服务器已经开启ing"
        hintLabel.textColor = .green
        hintLabel.isHidden = false
    }
    
    @IBAction func stopServer(_ sender: Any) {
        serverMgr.stopRunning()
        hintLabel.text = "服务器未开启"
        hintLabel.textColor = .red
        hintLabel.isHidden = false
    }
}

