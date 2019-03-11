//
//  SettingDetail-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/3/5.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.hero.modifiers = [.fade, .translate(x: 50)]
        
        saveButton.isEnabled = false
        
        print("Detail \(isAdd) \(isRouter)")
        
        detail_init()
        if !isAdd {
            let r = getUserConfig(name: self.name)
            nameText.text = r.name
            addressText.text = r.address
            loginNameText.text = r.loginName
            loginPasswordText.text = r.loginPassword
            portText.text = "\(r.port)"
        }
    }

    func detail_init() {
        if !isRouter {
            // ssh
            formTitle.text = "SSH Connect"
            protocolLabel.isHidden = true
            radioHttpButton.isHidden = true
            radioHttpsButton.isHidden = true
            tipLabel.isHidden = true
            addressTop.constant = 10
            radioSelected(selected: .ssh)
        } else {
            // router
            formTitle.text = "Router Connect"
            radioSelected(selected: .http)
            nameText.isEnabled = false
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
        radioHttpButton.layer.borderColor = UIColor.gray92.cgColor
        radioHttpsButton.layer.borderColor = UIColor.gray92.cgColor
        switch selected {
        case .http:
            radioHttpButton.layer.borderColor = UIColor.mainBlue.cgColor
            radioButtonValue = .http
        case .https:
            radioHttpsButton.layer.borderColor = UIColor.mainBlue.cgColor
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
    
    @IBAction func saveAction(_ sender: UIButton) {
        let uConfig = userConfig(
            name: nameText.text ?? "",
            mode: radioButtonValue.rawValue,
            address: addressText.text ?? "",
            port: (portText.text! as NSString).integerValue,
            loginName: loginNameText.text ?? "",
            loginPassword: loginPasswordText.text ?? "")
        
        let rSave = saveUserConfig(userConfig: uConfig)
        if rSave.0 {
            dismiss(animated: true, completion: nil)
        } else {
            messageNotification(message: "save Error")
        }
    }
    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }



}
