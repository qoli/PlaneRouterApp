//
//  Subscribe-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/27.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import JGProgressHUD

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
            self.addressTextView.text = self.linkb64?.removingWhitespacesAndNewlines.base64Decoded()
        })
    }

    // segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goCommandReadSegue" {
            if let destinationVC = segue.destination as? CommnadRead_ViewController {
                destinationVC.script = "ss_online_update.sh"
            }
        }
    }

    // story action

    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    // Button Radion
    
    let UserDefaultsKey = "saveOption"
    
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
        saveButton.layer.borderColor = UIColor.gray92.cgColor
        saveUpdateButton.layer.borderColor = UIColor.gray92.cgColor
        removeButton.layer.borderColor = UIColor.gray92.cgColor
        switch check {
        case .remove:
            removeButton.layer.borderColor = UIColor.coralPink.cgColor
        case .saveOnly:
            saveButton.layer.borderColor = UIColor.mainBlue.cgColor
        case .saveUpdate:
            saveUpdateButton.layer.borderColor = UIColor.mainBlue.cgColor
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
    
    var hud: JGProgressHUD!

    @IBAction func applyAction(_ sender: UIButton) {

        delay(0) {
            self.hud = JGProgressHUD(style: .dark)
            self.hud.show(in: self.view)
        }
        
        delay {
            _ = SSHRun(command: "dbus set ss_online_links=\(self.linkb64 ?? "")")
            _ = SSHRun(command: "dbus set ss_online_action=\(self.updateOptionwithUserDefaults().rawValue)")
            
            self.performSegue(withIdentifier: "goCommandReadSegue", sender: nil)
        }
        
        delay {
            self.hud.dismiss(afterDelay: 1.0)
        }

    }

    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.linkb64 = self.addressTextView.text.base64Encoded()
        self.applyButton.isEnabled = true
    }


}
