//
//  RouterSetting-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/7.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import JGProgressHUD
import NotificationBannerSwift

class Setting_ViewController: UIViewController {

    var ViewTitle = "Setting"
    var hud: JGProgressHUD!

    @IBOutlet weak var ViewTitleLabel: UILabel!

    // Form
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!

    @IBOutlet weak var serverAddress: UITextField!
    @IBOutlet weak var serverUser: UITextField!
    @IBOutlet weak var serverPass: UITextField!

    // Button
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.isEnabled = true

        backButton.hero.modifiers = [.fade, .translate(x: 50)]

        self.form_init()
        self.ViewTitleLabel.text = ViewTitle
    }

    // Back
    @IBAction func backAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tapView(_ sender: Any) {
        view.endEditing(true)
    }

    // MARK: - IBAction
    
    @IBAction func saveAction(_ sender: UIButton) {
        UserDefaults.standard.set(addressTextField.text, forKey: "routerAddress")
        UserDefaults.standard.set(userTextField.text, forKey: "routerUser")
        UserDefaults.standard.set(passTextField.text, forKey: "routerPass")
        UserDefaults.standard.set(serverAddress.text, forKey: "serverAddress")
        UserDefaults.standard.set(serverUser.text, forKey: "serverUser")
        UserDefaults.standard.set(serverPass.text, forKey: "serverPass")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cleanAction(_ sender: Any) {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            //hud
            let banner = NotificationBanner(title: "Clean", subtitle: "Cleaned finish", style: .success)
            banner.show()
        }
    }

    @IBAction func addressTextField(_ sender: UITextField) {
        self.ifTextFieldEmpty(sender: sender)
    }

    @IBAction func userTextField(_ sender: UITextField) {
        self.ifTextFieldEmpty(sender: sender)
    }

    @IBAction func passwordTextField(_ sender: UITextField) {
        self.ifTextFieldEmpty(sender: sender)
    }

    // MARK: - Form
    func form_init() {
        addressTextField.text = UserDefaults.standard.string(forKey: "routerAddress") ?? "192.168.1."
        userTextField.text = UserDefaults.standard.string(forKey: "routerUser") ?? ""
        passTextField.text = UserDefaults.standard.string(forKey: "routerPass") ?? ""
        serverAddress.text = UserDefaults.standard.string(forKey: "serverAddress") ?? ""
        serverUser.text = UserDefaults.standard.string(forKey: "serverUser") ?? ""
        serverPass.text = UserDefaults.standard.string(forKey: "serverPass") ?? ""
    }
    
    func ifTextFieldEmpty(sender: UITextField) {
        if (addressTextField.text?.isEmpty)! || (userTextField.text?.isEmpty)! || (passTextField.text?.isEmpty)! {
            // ...
        } else {
            saveButton.isEnabled = true
        }
    }
}
