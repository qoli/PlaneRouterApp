//
//  SettingDetail-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/3/5.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Localize_Swift

class SettingDetail_ViewController: UIViewController {

    //MARK: - IB VAR
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var portText: UITextField!
    @IBOutlet weak var loginNameText: UITextField!
    @IBOutlet weak var loginPasswordText: UITextField!
    @IBOutlet weak var radioHttpButton: UIButton!
    @IBOutlet weak var radioHttpsButton: UIButton!
    @IBOutlet weak var protocolLabel: UILabel!
    @IBOutlet weak var addressTop: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var formTitle: UILabel!
    
    
    //MARK: - Detail
    var isRouter: Bool = true
    var isAdd: Bool = true
    var name: String = ""
    var config: connectClass.ConnectStruct!

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.hero.modifiers = [.fade, .translate(x: 50)]
        
        saveButton.isEnabled = false
        
        print("Setting Detail Page - New: \(isAdd) isRouter: \(isRouter)")
        
        detail_init()
    }

    func detail_init() {
        if !isAdd {
            // Edit Mode
            nameText.text = config.name
            addressText.text = config.address
            loginNameText.text = config.loginName
            loginPasswordText.text = config.loginPassword
            portText.text = "\(config.port)"
            removeButton.isHidden = false
            print(config)
        }
        
        if !isRouter {
            // ssh
            formTitle.text = "SSH Connect".localized()
            protocolLabel.isHidden = true
            radioHttpButton.isHidden = true
            radioHttpsButton.isHidden = true
            tipLabel.isHidden = true
            addressTop.constant = 10
            radioSelected(selected: .ssh)
        } else {
            // router
            formTitle.text = "Router Connect".localized()
            radioSelected(selected: .http)
            nameText.isEnabled = false
            removeButton.isHidden = true
        }
    }

    // MARK: - IB Action
    

    // MARK: Radio
    
    var radioButtonValue: radioButton!
    
    enum radioButton: String {
        case http = "http"
        case https = "https"
        case ssh = "ssh"
    }
    
    func radioSelected(selected: radioButton) {
        radioHttpButton.layer.borderColor = UIColor(named: "gray92")?.cgColor
        radioHttpsButton.layer.borderColor = UIColor(named: "gray92")?.cgColor
        switch selected {
        case .http:
            radioHttpButton.layer.borderColor = UIColor(named: "mainBlue")?.cgColor
            radioButtonValue = .http
        case .https:
            radioHttpsButton.layer.borderColor = UIColor(named: "mainBlue")?.cgColor
            radioButtonValue = .https
        case .ssh:
            radioButtonValue = .ssh
        }
    }

    @IBAction func radioHttpAction(_ sender: UIButton) {
        radioSelected(selected: .http)
    }
    @IBAction func radioHttpsAction(_ sender: UIButton) {
        radioSelected(selected: .https)
    }
    
    // MARK: Form check
    
    func formCheck() {
        if (nameText.text?.isEmpty)! || (addressText.text?.isEmpty)! || (portText.text?.isEmpty)! || (loginNameText.text?.isEmpty)! || (loginPasswordText.text?.isEmpty)! {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    // MARK: back & save
    
    @IBAction func tapView(_ sender: Any) {
        formCheck()
        view.endEditing(true)
    }
    
    @IBOutlet weak var removeButton: UIButton!
    @IBAction func removeAction(_ sender: Any) {
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Delete".localized(), style: .destructive, handler: { _ in
            ConnectConfig.remove(identifier: self.config.identifier)
            self.dismiss(animated: true, completion: nil)
        })
        
        // 3
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func saveAction(_ sender: UIButton) {
        
        let portString: String! = portText?.text ?? "0"
        let port: Int64 = (portString! as NSString).longLongValue
        if isAdd {
            // New Mode
            _ = ConnectConfig.buildConnectConfig(
                name: nameText.text ?? "",
                mode: connectClass.connectMode(rawValue: radioButtonValue.rawValue)!,
                address: addressText.text ?? "",
                port: port,
                loginName: loginNameText.text ?? "",
                loginPassword: loginPasswordText.text ?? "",
                type: .Server
            )
        } else {
            // Edit Mode
            config.name = nameText.text ?? ""
            config.mode = connectClass.connectMode(rawValue: radioButtonValue.rawValue)!
            config.address = addressText.text ?? ""
            config.port = port
            config.loginName = loginNameText.text ?? ""
            config.loginPassword = loginPasswordText.text ?? ""
            
            ConnectConfig.updateConnectConfig(connect: config)
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }



}
