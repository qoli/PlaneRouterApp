//
//  SS-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/22.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import Alamofire
import SwiftyJSON
import PopMenu


class Connect_ViewController: UIViewController {

    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageDesc: UILabel!
    @IBOutlet weak var pageButton: UIButton!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusTimeLabel: UILabel!

    @IBOutlet weak var lineListButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!

    var isAppear = false

    override func viewDidLoad() {
        super.viewDidLoad()

        //添加通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ConnectViewonShowNotification(_:)),
            name: NSNotification.Name(rawValue: "ConnectViewonShow"),
            object: nil
        )
        
        pageDesc.text = "SSH: Router"

    }

    //MARK: 通知
    
    @objc func ConnectViewonShowNotification(_ notification: Notification) {
        if notification.object! as! Bool {
            self.isAppear = true
            self.loop()
        }

    }
    
    //MARK: View 生命週期處理
    
    override func viewWillDisappear(_ animated: Bool) {
        isAppear = false
    }

    override func viewWillAppear(_ animated: Bool) {
        print("checkSSInstall: \(checkSSInstall())")
        self.loop()
        if checkSSInstall() {
            lineButtonUpdate()
        }
    }
    
    //MARK: IBAction
    
    @IBAction func pageMoreAction(_ sender: UIButton) {
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        let controller = PopMenuViewController(sourceView: self.pageButton, actions: [
            PopMenuDefaultAction(
                title: "ACL Setting",
                image: UIImage(named: "iconFontNetworkWired"),
                didSelect: { action in
                    delay {
                        self.performSegue(withIdentifier: "goACLSegue", sender: nil)
                    }
            }
            ),
            PopMenuDefaultAction(
                title: "Subscribe",
                image: UIImage(named: "iconFontServer"),
                didSelect: { action in
                    delay {
                        self.performSegue(withIdentifier: "goSubscribeSegue", sender: nil)
                    }
            }
            ),
            PopMenuDefaultAction(
                title: "Add a Hosts",
                image: UIImage(named: "iconFontPlusCircle"),
                didSelect: { action in
                    //
            }
            ),
            ])
        
        controller.shouldDismissOnSelection = true
        present(controller, animated: true, completion: nil)
    }

    @IBAction func DropdownListAction(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.performSegue(withIdentifier: "goListSegue", sender: nil)
    }

    @IBAction func ConnectAction(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.performSegue(withIdentifier: "goCommandReadSegue", sender: nil)
    }

    //MARK: 檢查 SS 安裝狀態
    
    func checkSSInstall() -> Bool {

        let cacheData = UserDefaults.standard.dictionary(forKey: "ssData") as? [String: String]
        
        if cacheData == nil {
            let ssEnable = SSHRun(command: "dbus get ss_basic_enable", isRefresh: true )
            if ssEnable == "\n" {
                delay(0) {
                    self.statusLabel.text = "Shadowsock not ready"
                }
                return false
            } else {
                if ssEnable == "0" {
                    delay(0) {
                        self.statusLabel.text = "Shadowsock not enable"
                    }
                    return false
                } else {
                    return true
                }

            }
        } else {
            return true
        }


    }

    //MARK: - Status loop
    
    // Status
    func loop() {
        
        if !isAppear {
            self.statusTimeLabel.text = "Pause"
            print("Connect_ViewController: Pause")
        }
        
        delay(2) {
            self.sendStatusRequest()
            if self.isAppear {
                self.loop()
            }
        }
    }

    // ARM Model
    func sendStatusRequest() {
        /**
         status
         get http://router.asus.com/ss_status
         */

        
        
        // Fetch Request
        Alamofire.request("\(buildUserURL())/ss_status", method: .get)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    //
                    let r = JSON(value)
                    if r[0].stringValue != "" {
                        let status = r[0].stringValue.groups(for: "color=(.*?)>国外连接 - \\[ (.*?) \\]")
                        if status[0][1] == "#fc0" {
                            self.updateStatusView(isSuccess: true, text: status[0][2])
                        } else {
                            self.updateStatusView(isSuccess: false, text: status[0][2])
                        }
                    }

                case .failure(_):
                    break
                }
            }
            .responseString { response in
                switch response.result {
                case .success(let value):
                    // check login
                    if value.hasPrefix("<HTML><HEAD><script>top.location.href='/Main_Login.asp'") {
                        GetRouterCookie()
                        self.statusTimeLabel.text = "Waiting for login"
                    } else {
                        self.connectButton.isEnabled = true
                        self.lineListButton.isEnabled = true
                    }

                case .failure(let error):
                    self.statusTimeLabel.text = error.localizedDescription
                }
        }
    }
    
    func updateStatusView(isSuccess: Bool, text: String) {
        if isSuccess {
            UIView.animate(withDuration: 0.4, animations: {
                self.statusLabel.text = "Success"
                self.statusView.backgroundColor = UIColor.appleGreen
                self.statusView.layer.shadowColor = UIColor.appleGreen.cgColor
                self.statusTimeLabel.text = text
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.statusLabel.text = "Failure"
                self.statusView.backgroundColor = UIColor.coralPink
                self.statusView.layer.shadowColor = UIColor.coralPink.cgColor
                self.statusTimeLabel.text = text
            })
        }
    }

    //MARK: - Line Button
    
    func lineButtonUpdate() {
        self.lineListButton.setTitle("...", for: .disabled)
        self.connectButton.setTitle("...", for: .disabled)
        self.lineListButton.isEnabled = false
        self.connectButton.isEnabled = false
        delay {
            updateSSData(isRefresh: true, completionHandler: {value,error in
                if value != [:] {
                    let node = value["ssconf_basic_node"] ?? ""
                    let name = value["ssconf_basic_name_\(node)"] ?? ""
                    self.lineListButton.setTitle(name, for: .normal)
                    self.connectButton.setTitle("Reconnect", for: .normal)
                    self.lineListButton.isEnabled = true
                    self.connectButton.isEnabled = true
                }
            })
        }
    }


}

