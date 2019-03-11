//
//  AddNode-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/3/11.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Alamofire

class AddNode_ViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var nodeModeName: UILabel!

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var protocolParam: UITextField!
    @IBOutlet weak var obfsTop: NSLayoutConstraint!
    @IBOutlet weak var obfsParamTitle: UILabel!
    @IBOutlet weak var obfsParam: UITextField!

    @IBOutlet weak var protocolTitle: UILabel!

    @IBOutlet weak var protocolParamTitle: UILabel!

    @IBOutlet weak var saveButton: UIButton!
    
    
    var isSSR: Bool = true
    var lastNumber: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get number
        updateSSData(completionHandler: { value, _ in
            if value != [:] {
                for v in value {
                    if v.key.hasPrefix("ssconf_basic_name_") {
                        self.lastNumber = self.lastNumber + 1
                    }
                }
            }
        })
        
        //
        nodeModeName.text = "ShadowsockR \(lastNumber)"
        
        saveButton.isEnabled = true
        
        if !isSSR {
            nodeModeName.text = "Shadowsock  \(lastNumber)"
            
            obfsParamTitle.text = "obfs Host"
            obfsTop.constant = 10
            obfsParamTitle.isHidden = true
            obfsParam.isHidden = true
            
            protocolTitle.isHidden = true
            protocolButton.isHidden = true
            protocolParamTitle.isHidden = true
            protocolParam.isHidden = true
        }
    }

    // MARK: - Close

    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tapView(_ sender: Any) {
        view.endEditing(true)
    }
    
    func saveDone() {
        view.endEditing(true)
        delay {
            self.performSegue(withIdentifier: "goListSegue", sender: nil)
        }
    }
    
    // MARK: prepare segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goListSegue" {
            if let destinationVC = segue.destination as? List_ViewController {
                destinationVC.goBottom = true
            }
        }
    }
    
    // MARK: save button action
    
    @IBAction func saveAction(_ sender: Any) {
        print(ModeListValue)
        print(ssMethodValue)
        print(rssProtocolValue)
        print(rssObfsValue)
        print(ssObfsValue)

        if isSSR {
            addSSRNode(
                mode: "\(ModeListValue)",
                name: name.text ?? "",
                server: address.text ?? "",
                port: port.text ?? "",
                method: ssMethodValue,
                password: password.text ?? "",
                rss_protocol: rssProtocolValue,
                rss_protocol_param: protocolParam.text ?? "",
                rss_obfs: rssObfsValue,
                rss_obfs_param: obfsParam.text ?? "")
        } else {
            addSSNode(
                mode: "\(ModeListValue)",
                name: name.text ?? "",
                server: address.text ?? "",
                port: port.text ?? "",
                method: ssMethodValue,
                password: password.text ?? "",
                ss_obfs: ssObfsValue,
                ss_obfs_host: obfsParam.text ?? "")
        }
        
    }

    
    

    // MARK: - Drop Menu
    
    var ModeListValue: Int = 1
    enum ModeList: Int, CaseIterable {
        case GFWList = 1
        case WhiteList = 2
        case GameMode = 3
        case Global = 4
        case backtoChina = 5

        var description: String {
            switch self {
            case .GFWList:
                return "GFW List"
            case .WhiteList:
                return "White List"
            case .GameMode:
                return "Game Mode"
            case .Global:
                return "Global"
            case .backtoChina:
                return "Back to China"
            }
        }
    }

    var ssMethodValue: String = "none"
    enum ss_method: String, CaseIterable {
        case none = "none"
        case rc4 = "rc4"
        case rc4md5 = "rc4-md5"
        case rc4md56 = "rc4-md5-6"
        case aes128gcm = "aes-128-gcm"
        case aes192gcm = "aes-192-gcm"
        case aes256gcm = "aes-256-gcm"
        case aes128cfb = "aes-128-cfb"
        case aes192cfb = "aes-192-cfb"
        case aes256cfb = "aes-256-cfb"
        case aes128ctr = "aes-128-ctr"
        case aes192ctr = "aes-192-ctr"
        case aes256ctr = "aes-256-ctr"
        case camellia128cfb = "camellia-128-cfb"
        case camellia192cfb = "camellia-192-cfb"
        case camellia256cfb = "camellia-256-cfb"
        case bfcfb = "bf-cfb"
        case cast5cfb = "cast5-cfb"
        case ideacfb = "idea-cfb"
        case rc2cfb = "rc2-cfb"
        case seedcfb = "seed-cfb"
        case salsa20 = "salsa20"
        case chacha20 = "chacha20"
        case chacha20ietf = "chacha20-ietf"
        case chacha20ietfpoly1305 = "chacha20-ietf-poly1305"
        case xchacha20ietfpoly1305case = "xchacha20-ietf-poly1305case"
    }

    var rssProtocolValue: String = "origin"
    enum rss_protocol: String, CaseIterable {
        case origin = "origin"
        case verify_simple = "verify_simple"
        case verify_sha1 = "verify_sha1"
        case auth_sha1 = "auth_sha1"
        case auth_sha1_v2 = "auth_sha1_v2"
        case auth_sha1_v4 = "auth_sha1_v4"
        case auth_aes128_md5 = "auth_aes128_md5"
        case auth_aes128_sha1 = "auth_aes128_sha1"
        case auth_chain_a = "auth_chain_a"
        case auth_chain_b = "auth_chain_b"
        case auth_chain_c = "auth_chain_c"
        case auth_chain_d = "auth_chain_d"
        case auth_chain_e = "auth_chain_e"
        case auth_chain_f = "auth_chain_f"
        case auth_akarin_rand = "auth_akarin_rand"
        case auth_akarin_spec_a = "auth_akarin_spec_a"
    }
    
    var rssObfsValue: String = "plain"
    enum rss_obfs: String, CaseIterable {
        case plain = "plain"
        case http_simple = "http_simple"
        case http_post = "http_post"
        case tls12_ticket_auth = "tls1.2_ticket_auth"
    }
    
    var ssObfsValue: String = "0"
    enum ss_obfs: String, CaseIterable {
        case none = "0"
        case http = "http"
        case tls = "tls"
    }

    @IBOutlet weak var modeButton: UIButton!
    @IBAction func modeAction(_ sender: UIButton) {
        buttonTapAnimate(button: self.modeButton)

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for mode in ModeList.allCases {
            alertController.addAction(
                UIAlertAction(
                    title: "\(mode.description)",
                    style: .default,
                    handler: { (action) -> Void in
                        self.modeButton.setTitle(mode.description, for: .normal)
                        self.ModeListValue = mode.rawValue
                    }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
    }

    @IBOutlet weak var encrytionButton: UIButton!
    @IBAction func encryptionAction(_ sender: Any) {
        buttonTapAnimate(button: self.encrytionButton)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for list in ss_method.allCases {
            alertController.addAction(
                UIAlertAction(
                    title: "\(list.rawValue)",
                    style: .default,
                    handler: { (action) -> Void in
                        self.encrytionButton.setTitle(list.rawValue, for: .normal)
                        self.ssMethodValue = list.rawValue
                }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
    }

    @IBOutlet weak var protocolButton: UIButton!
    @IBAction func protocolAction(_ sender: Any) {
        buttonTapAnimate(button: self.protocolButton)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for list in rss_protocol.allCases {
            alertController.addAction(
                UIAlertAction(
                    title: "\(list.rawValue)",
                    style: .default,
                    handler: { (action) -> Void in
                        self.protocolButton.setTitle(list.rawValue, for: .normal)
                        self.rssProtocolValue = list.rawValue
                }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
    }


    @IBOutlet weak var obfsButton: UIButton!
    @IBAction func obfsAction(_ sender: Any) {
        buttonTapAnimate(button: self.obfsButton)
        switch isSSR {
        case true:
            // ssr
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            for list in rss_obfs.allCases {
                alertController.addAction(
                    UIAlertAction(
                        title: "\(list.rawValue)",
                        style: .default,
                        handler: { (action) -> Void in
                            self.obfsButton.setTitle(list.rawValue, for: .normal)
                            self.rssObfsValue = list.rawValue
                    }))
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alertController, animated: true, completion: nil)
        case false:
            // ss
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            for list in ss_obfs.allCases {
                var listName = list.rawValue
                if list.rawValue == "0" {
                    listName = "none"
                }
                alertController.addAction(
                    UIAlertAction(
                        title: "\(listName)",
                        style: .default,
                        handler: { (action) -> Void in
                            self.obfsButton.setTitle(listName, for: .normal)
                            self.ssObfsValue = list.rawValue
                            if list.rawValue != "0" {
                                self.obfsParamTitle.isHidden = false
                                self.obfsParam.isHidden = false
                            }
                    }))
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alertController, animated: true, completion: nil)
        }
    }




    // MARK: - animate

    func buttonTapAnimate(button: UIButton) {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                button.alpha = 0.3
            },
            completion: { _ in
                UIView.animate(withDuration: 0.6, animations: {
                    button.alpha = 1
                })
            })
    }

    // MARK: - add nodes
    
    func addSSNode(
        mode: String,
        name: String,
        server: String,
        port: String,
        method: String,
        password: String,
        ss_obfs: String,
        ss_obfs_host: String) {
        if name == "" {
            messageNotification(message: "name cannot empty")
        }
        
        let urlParams = [
            "p":"ssconf_basic",
            "ssconf_basic_type_\(lastNumber)":"0",
            "ssconf_basic_password_\(lastNumber)":"\(password)",
            
            "ssconf_basic_mode_\(lastNumber)":"\(mode)",
            "ssconf_basic_name_\(lastNumber)":"\(name)",
            "ssconf_basic_server_\(lastNumber)":"\(server)",
            "ssconf_basic_port_\(lastNumber)":"\(port)",
            "ssconf_basic_method_\(lastNumber)":"\(method)",
            
            "ssconf_basic_ss_obfs_\(lastNumber)":"\(ss_obfs)",
            "ssconf_basic_ss_obfs_host_\(lastNumber)":"\(ss_obfs_host)",
            ]
        
        switch ModelPage.runningModel {
        case .arm:
            // Fetch Request
            Alamofire.request("\(buildUserURL())/applydb.cgi", method: .get, parameters: urlParams)
                .validate(statusCode: 200..<300)
                .responseString(encoding: String.Encoding.utf8) { response in
                    if (response.result.error == nil) {
                        self.saveDone()
                    }
                    else {
                        messageNotification(message: response.result.error?.localizedDescription ?? "error")
                    }
            }
        case .hnd:
            // JSON Body
            let body: [String : Any] = [
                "fields": [urlParams],
                "id": 88172779,
                "method": "dummy_script.sh",
                "params": []
            ]
            
            // Fetch Request
            Alamofire.request("\(buildUserURL())/_api/", method: .post, parameters: body, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    if (response.result.error == nil) {
                        self.saveDone()
                    }
                    else {
                        messageNotification(message: response.result.error?.localizedDescription ?? "error")
                    }
            }
            
        }// end switch
    }
    
    func addSSRNode(
        mode: String,
        name: String,
        server: String,
        port: String,
        method: String,
        password: String,
        rss_protocol: String,
        rss_protocol_param: String,
        rss_obfs: String,
        rss_obfs_param: String) {
        
        if name == "" {
            messageNotification(message: "name cannot empty")
        }
        
        let urlParams = [
            "p":"ssconf_basic",
            "ssconf_basic_type_\(lastNumber)":"1",
            "ssconf_basic_password_\(lastNumber)":"\(password)",
            
            "ssconf_basic_mode_\(lastNumber)":"\(mode)",
            "ssconf_basic_name_\(lastNumber)":"\(name)",
            "ssconf_basic_server_\(lastNumber)":"\(server)",
            "ssconf_basic_port_\(lastNumber)":"\(port)",
            "ssconf_basic_method_\(lastNumber)":"\(method)",
            
            "ssconf_basic_rss_protocol_\(lastNumber)":"\(rss_protocol)",
            "ssconf_basic_rss_protocol_param_\(lastNumber)":"\(rss_protocol_param)",
            "ssconf_basic_rss_obfs_\(lastNumber)":"\(rss_obfs)",
            "ssconf_basic_rss_obfs_param_\(lastNumber)":"\(rss_protocol_param)",
            ]
        
        switch ModelPage.runningModel {
        case .arm:
            // Fetch Request
            Alamofire.request("\(buildUserURL())/applydb.cgi", method: .get, parameters: urlParams)
                .validate(statusCode: 200..<300)
                .responseString(encoding: String.Encoding.utf8) { response in
                    if (response.result.error == nil) {
                        self.saveDone()
                    }
                    else {
                        messageNotification(message: response.result.error?.localizedDescription ?? "error")
                    }
            }
        case .hnd:
            // JSON Body
            let body: [String : Any] = [
                "fields": [urlParams],
                "id": 88172779,
                "method": "dummy_script.sh",
                "params": []
            ]
            
            // Fetch Request
            Alamofire.request("\(buildUserURL())/_api/", method: .post, parameters: body, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    if (response.result.error == nil) {
                        self.saveDone()
                    }
                    else {
                        messageNotification(message: response.result.error?.localizedDescription ?? "error")
                    }
            }
            
        }// end switch
    }
}
