//
//  Subscribe-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/27.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Chrysan

class Subscribe_ViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var addressTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveUpdateButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    
    
    enum saveOptin: Int {
        case remove = 1
        case saveOnly = 2
        case saveUpdate = 3
    }
    
//    var saveValue: saveOptin = .saveUpdate
    
    var linkb64: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addressTextView.delegate = self
        
        updateTextField(isR: false)
        
        saveRadio(check: updateOptionwithUserDefaults())
    }
    
    func updateTextField(isR: Bool = false) {
        updateSSData(isRefresh: isR, completionHandler: { value, error in
            self.linkb64 = value["ss_online_links"] ?? ""
            self.addressTextView.text = self.linkb64?.removingWhitespacesAndNewlines.base64Decoded() ?? ""
        })
    }

    // segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goCommandReadSegue" {
            if let destinationVC = segue.destination as? CommnadRead_ViewController {
                destinationVC.script = "ss_online_update.sh"
                // params 1 刪除 2 僅保存 3 開始訂閱 4 通過鏈接增加節點
                destinationVC.params = "\(self.updateOptionwithUserDefaults().rawValue)"
            }
        }
    }

    // story action

    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    // Button Radion
    
    let UserDefaultsKey = "com.qoli.saveSubscribeOption"
    
    func updateOptionwithUserDefaults() -> saveOptin {
        let checkValue = UserDefaults.standard.integer(forKey: UserDefaultsKey)
        if checkValue == 0 {
            return saveOptin.saveUpdate
        } else {
            return saveOptin(rawValue: checkValue)!
        }
    }
    func saveOptiontoUserDefaults(check: saveOptin) {
        UserDefaults.standard.set(check.rawValue, forKey: UserDefaultsKey)
    }

    func saveRadio(check: saveOptin) {
        saveButton.layer.borderColor = UIColor(named: "gray92")?.cgColor
        saveUpdateButton.layer.borderColor = UIColor(named: "gray92")?.cgColor
        removeButton.layer.borderColor = UIColor(named: "gray92")?.cgColor
        switch check {
        case .remove:
            removeButton.layer.borderColor = UIColor(named: "coralPink")?.cgColor
        case .saveOnly:
            saveButton.layer.borderColor = UIColor(named: "mainBlue")?.cgColor
        case .saveUpdate:
            saveUpdateButton.layer.borderColor = UIColor(named: "mainBlue")?.cgColor
        }
        
        self.applyButton.isEnabled = true
        saveOptiontoUserDefaults(check: check)
    }
    
    @IBAction func SaveAction(_ sender: Any) {
        saveRadio(check: .saveOnly)
    }
    
    @IBAction func SaveUpdateAction(_ sender: Any) {
        saveRadio(check: .saveUpdate)
    }
    @IBAction func RemoveAction(_ sender: Any) {
        saveRadio(check: .remove)
    }

    @IBAction func applyAction(_ sender: UIButton) {
        self.linkb64 = self.addressTextView.text.base64Encoded()
        
        delay(0) {
            self.chrysan.show()
        }
        
        delay {
            switch routerModel.runningModel {
            case .arm:
                _ = SSHRun(command: "dbus set ss_online_links=\(self.linkb64 ?? "")")
                _ = SSHRun(command: "dbus set ss_online_action=\(self.updateOptionwithUserDefaults().rawValue)")
            case .hnd:
                _ = SSHRun(command: "dbus set ss_online_links=\(self.linkb64 ?? "")")
            }
            
            self.performSegue(withIdentifier: "goCommandReadSegue", sender: nil)
        }
        
        delay {
            self.chrysan.show(hideDelay: 1)
        }

    }

    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }


}
