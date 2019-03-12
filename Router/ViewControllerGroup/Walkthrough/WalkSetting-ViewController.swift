//
//  WalkSetting-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/3/1.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import NMSSH
import NotificationBannerSwift
import SafariServices

class WalkSetting_ViewController: UIViewController {

    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var linkView: UIView!

    @IBOutlet weak var saveButton: UIButton!

    var isTest: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
    }

    // ib action

    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }


    @IBAction func tapLinkAction(_ sender: UITapGestureRecognizer) {
        print("tap")
        self.linkView.alpha = 0.3
        delay(0.1) {
            self.linkView.alpha = 1
        }
        let url = NSURL(string: "https://github.com/qoli/AtomicR/blob/master/Tutorial/HowtoSSH.md")
        let svc = SFSafariViewController(url: url! as URL)
        present(svc, animated: true, completion: nil)
    }
    @IBAction func passEnd(_ sender: UITextField) {
        if !self.pass.text!.isEmpty {
            saveButton.isEnabled = true
        }
    }

    var banner: NotificationBanner!

    @IBAction func saveAction(_ sender: UIButton) {
        if isTest {
            self.performSegue(withIdentifier: "goWlakDoneSegue", sender: nil)
        } else {
            saveButton.isEnabled = false
            self.saveButton.setTitle("驗證中", for: .normal)
            banner = NotificationBanner(title: "設定路由器", subtitle: "...", style: .info)
            banner.show()
            banner.subtitleLabel?.text = "開始嘗試連接"

            delay(0.6) {
                
                _ = ConnectConfig.routerConfig(
                    mode: .http,
                    address: self.address.text ?? "router.asus.com",
                    port: 80,
                    loginName: self.name.text ?? "",
                    loginPassword: self.pass.text ?? "",
                    type: .Router
                )

//                let uConfig = userConfig(
//                    name: "Router",
//                    mode: "http",
//                    address: self.address.text ?? "router.asus.com",
//                    port: 80,
//                    loginName: self.name.text ?? "",
//                    loginPassword: self.pass.text ?? "")

//                let r = saveUserConfig(userConfig: uConfig)
//                ConnectConfig.add(connect: config)
                
                self.SSHRun()
            }
        }

    }
    
    // check

    func SSHRun() {

        let uConfig = ConnectConfig.getRouter()

        print(uConfig)

        let host = uConfig.address
        let username = uConfig.loginName
        let password = uConfig.loginPassword

        let session = NMSSHSession(host: host , andUsername: username)
        session.connect()

        if session.isConnected {
            session.authenticate(byPassword: password )

            if session.isAuthorized {
                banner.subtitleLabel?.text = "驗證成功"
                saveButton.isEnabled = true
                self.saveButton.setTitle("設定完畢", for: .normal)
                self.isTest = true
                self.performSegue(withIdentifier: "goWlakDoneSegue", sender: nil)
            } else {
                banner.subtitleLabel?.text = "驗證失敗，請檢查賬號密碼是否正確"
                self.saveButton.setTitle("驗證", for: .normal)
                saveButton.isEnabled = true
            }

        } else {
            banner.subtitleLabel?.text = "連線失敗，請檢查是否啟用 SSH 連線功能"
            self.saveButton.setTitle("驗證", for: .normal)
            saveButton.isEnabled = true
        }

    }

}
