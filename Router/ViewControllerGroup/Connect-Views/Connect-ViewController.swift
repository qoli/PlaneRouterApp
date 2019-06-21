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
import PlainPing
import Localize_Swift

class Connect_ViewController: UIViewController {

    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageDesc: UILabel!
    @IBOutlet weak var pageButton: UIButton!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusTimeLabel: UILabel!

    @IBOutlet weak var lineListButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!

    var isLooping = false

    override func viewDidLoad() {
        super.viewDidLoad()

        //添加通知
        addNotification()

        pageDesc.text = "SSH: Router".localized()
    }

    //MARK: - 通知

    func addNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ConnectViewonShowNotification(_:)),
            name: NSNotification.Name(rawValue: "ConnectViewonShow"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ConnectViewonListNotification(_:)),
            name: NSNotification.Name(rawValue: "ConnectViewonList"),
            object: nil
        )
    }

    @objc func ConnectViewonShowNotification(_ notification: Notification) {
        if notification.object! as! Bool {
//            self.isLooping = true
//            self.loopUpdateStatus()
        }
    }


    @objc func ConnectViewonListNotification(_ notification: Notification) {
        pageDesc.text = "\(App.appListON)"
    }

    //MARK: - View 生命週期處理

    override func viewWillDisappear(_ animated: Bool) {
        isLooping = false
        print("viewWillDisappear")
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
//        self.loopUpdateStatus()
        if checkSSInstall() {
            lineButtonUpdate()
        }
    }



    //MARK: - page more action

    @IBAction func pageMoreAction(_ sender: UIButton) {

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let controller = PopMenuViewController(sourceView: self.pageButton, actions: [
            PopMenuDefaultAction(
                title: "Add node".localized(),
                image: UIImage(named: "iconFontPlusCircle"),
                didSelect: { action in
                    delay {
                        self.addNodePopMenu()
                    }
                }
            ),
            PopMenuDefaultAction(
                title: "Subscribe".localized(),
                image: UIImage(named: "iconFontServer"),
                didSelect: { action in
                    delay {
                        self.performSegue(withIdentifier: "goSubscribeSegue", sender: nil)
                    }
                }
            ),
            PopMenuDefaultAction(
                title: "Nodes".localized(),
                image: UIImage(named: "iconFontThList"),
                didSelect: { action in
                    delay {
                        self.performSegue(withIdentifier: "goListSegue", sender: nil)
                    }
                }
            ),
            PopMenuDefaultAction(
                title: "ACL Setting".localized(),
                image: UIImage(named: "iconFontNetworkWired"),
                didSelect: { action in
                    delay {
                        self.performSegue(withIdentifier: "goACLSegue", sender: nil)
                    }
                }
            ),
        ])

        controller.shouldDismissOnSelection = true
        present(controller, animated: true, completion: nil)
    }

    var isSSR: Bool = false

    func addNodePopMenu() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let controller = PopMenuViewController(actions: [
            PopMenuDefaultAction(
                title: "URI (ss:// or ssr://)",
                didSelect: { action in
                    delay {
                        //1. Create the alert controller.
                        let alert = UIAlertController(title: "URI", message: "ss:// or ssr://", preferredStyle: .alert)

                        //1.1 cancel button
                        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                            //cancel code
                        }
                        alert.addAction(cancelAction)

                        //2. Add the text field. You can configure it however you need.
                        alert.addTextField { (textField) in
                            textField.placeholder = "ss:// or ssr://"
                        }

                        // 3. Grab the value from the text field, and print it when the user clicks OK.
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                            if textField.text?.hasPrefix("ss://") ?? false || textField.text?.hasPrefix("ssr://") ?? false {
                                _ = SSHRun(command: "dbus set ss_online_action=4")
                                self.script = "ss_online_update.sh"
                                self.ssLinks = textField.text ?? ""
                                self.performSegue(withIdentifier: "goCommandReadSegue", sender: nil)
                            } else {
                                messageNotification(message: "Invalid URI")
                            }

                        }))

                        // 4. Present the alert.
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            ),
            PopMenuDefaultAction(
                title: "Shadowsock",
                didSelect: { action in
                    delay {
                        self.isSSR = false
                        self.performSegue(withIdentifier: "goAddNodeSegue", sender: nil)
                    }
                }
            ),
            PopMenuDefaultAction(
                title: "ShadowsockR",
                didSelect: { action in
                    delay {
                        self.isSSR = true
                        self.performSegue(withIdentifier: "goAddNodeSegue", sender: nil)
                    }
                }
            ),
        ])

        controller.appearance.popMenuActionCountForScrollable = 10
        present(controller, animated: true, completion: nil)
    }

    // MARK: Segue pass data

    var goButton: Bool = false
    var script: String = "ss_config.sh"
    var ssLinks: String = ""

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goAddNodeSegue" {
            if let destinationVC = segue.destination as? AddNode_ViewController {
                destinationVC.isSSR = self.isSSR
            }
        }
        if segue.identifier == "goCommandReadSegue" {
            if let destinationVC = segue.destination as? CommnadRead_ViewController {
                destinationVC.script = self.script
                destinationVC.ssLinks = self.ssLinks
            }
        }
    }

    // MARK: - button

    @IBAction func DropdownListAction(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.performSegue(withIdentifier: "goListSegue", sender: nil)
    }

    @IBAction func ConnectAction(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        self.performSegue(withIdentifier: "goCommandReadSegue", sender: nil)
    }

    //MARK: - 檢查 SS 安裝狀態

    func checkSSInstall() -> Bool {

        let cacheData = UserDefaults.standard.dictionary(forKey: "ssData") as? [String: String]

        if cacheData == nil {
            let ssEnable = SSHRun(command: "dbus get ss_basic_enable", isRefresh: true)
            if ssEnable == "\n" {
                delay(0) {
                    self.statusLabel.text = "Shadowsock not ready".localized()
                }
                return false
            } else {
                if ssEnable == "0" {
                    delay(0) {
                        self.statusLabel.text = "Shadowsock not enable".localized()
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

    // MARK: - Status Update

    // Status
    func loopUpdateStatus(isLoop: Bool = false) {

        if isLoop == true {
            self.isLooping = true
            self.Status_inAppUpdate()
        } else {
            self.loopLabel.text = "Pause, Tap to Continue"
            self.updateStatusView(isSuccess: true, text: "", isPause: true)
        }
        
    }

    
    @IBOutlet weak var loopLabel: UILabel!
    
    @IBAction func tapStatus(_ sender: UITapGestureRecognizer) {
        if self.isLooping == true {
            self.loopUpdateStatus(isLoop: false)
            self.isLooping = false
        } else {
            self.loopUpdateStatus(isLoop: true)
        }
    }
    
    
    func Status_inAppUpdate() {

        let StartTime = Date.timeIntervalSinceReferenceDate
        self.loopLabel.text = "···"
        
        Alamofire.request("https://www.google.com.hk/generate_204")
            .responseString { response in
                let EndTime = Date.timeIntervalSinceReferenceDate
                let delayTime = (EndTime - StartTime) * 1000
                
                switch response.result {
                case .success(_):
                    if let headers = response.response?.allHeaderFields as? [String: String] {
                        print("\(headers["Date"] ?? "") \(EndTime) \(StartTime) \(delayTime)")
                        self.updateStatusView(isSuccess: true, text: "\(String(format: "%.3f", delayTime)) ms")
//                        self.loopLabel.text = "***"
                        
                        delay(1) {
                            self.loopLabel.text = "*··"
                            delay(1) {
                                self.loopLabel.text = "·*·"
                                delay(1) {
                                    self.loopLabel.text = "··*"
                                    delay(1) {
                                        self.loopUpdateStatus(isLoop: self.isLooping)
                                    }
                                }
                            }
                        }

                    }
                case .failure(let error):
                    self.isLooping = false
                    self.loopUpdateStatus(isLoop: self.isLooping)
                    self.updateStatusView(isSuccess: false, text: "\(error.localizedDescription) · \(String(format: "%.2f", delayTime)) ms")
                }

        }
    }

    func Status_Update() {

        switch ModelPage.runningModel {
        case .arm:
            // Fetch Request
            Alamofire.request("\(buildUserURL())/\(ModelPage.Status)", method: .get)
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
        case .hnd:
            fetchRequest(
                api: "\(buildUserURL())/\(ModelPage.Status)",
                isRefresh: true,
                completionHandler: { value, error in
                    if value != nil {
                        let r = JSON(value as Any)
                        if r["result"].stringValue != "" {
                            let status = r["result"].stringValue.groups(for: "国外链接 【(.*?)】 (.*?)&nbsp;&nbsp;(.*?) ms")
                            if status[0][2] == "✓" {
                                self.updateStatusView(isSuccess: true, text: "\(status[0][1]) \(status[0][3]) ms")
                            } else {
                                self.updateStatusView(isSuccess: false, text: "\(status[0][1])")
                            }
                        }
                    }
                })
        }

    }

    func updateStatusView(isSuccess: Bool, text: String, isPause: Bool = false) {
        
        if isPause {
            UIView.animate(withDuration: 0.8, animations: {
                self.statusView.backgroundColor = UIColor.gray80
                self.statusView.layer.shadowColor = UIColor.gray80.cgColor
            })
            
        } else {
            if isSuccess {
                UIView.animate(withDuration: 0.4, animations: {
                    self.statusLabel.text = "Google.com".localized()
                    self.statusView.backgroundColor = UIColor.appleGreen
                    self.statusView.layer.shadowColor = UIColor.appleGreen.cgColor
                    self.statusTimeLabel.text = text
                })
            } else {
                UIView.animate(withDuration: 0.4, animations: {
                    self.statusLabel.text = "Failure".localized()
                    self.statusView.backgroundColor = UIColor.coralPink
                    self.statusView.layer.shadowColor = UIColor.coralPink.cgColor
                    self.statusTimeLabel.text = text
                })
            }
        }
    }

    //MARK: - Line Button

    func lineButtonUpdate() {
        self.lineListButton.setTitle("...", for: .disabled)
        self.connectButton.setTitle("...", for: .disabled)
        self.lineListButton.isEnabled = false
        self.connectButton.isEnabled = false
        //
        updateSSData(isRefresh: true, completionHandler: { value, error in
            if value != [:] {
                let node = value["ssconf_basic_node"] ?? ""
                let name = value["ssconf_basic_name_\(node)"] ?? ""
                self.lineListButton.setTitle(name, for: .normal)
                self.connectButton.setTitle("Reconnect".localized(), for: .normal)
                self.lineListButton.isEnabled = true
                self.connectButton.isEnabled = true
            }
        })
    }


}

