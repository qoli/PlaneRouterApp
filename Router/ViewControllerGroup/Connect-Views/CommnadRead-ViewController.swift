//
//  CommnadRead-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/23.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import Alamofire
import SwiftyJSON
import JGProgressHUD

class CommnadRead_ViewController: UIViewController {

    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    //
    var isAppear = true
    var script = "ss_config.sh"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ApplydbSS()
        loop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isAppear = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isAppear = false
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //
    
    func loop() {
        self.CommnadReadAjax()
        delay(2) {
            if self.isAppear {
                self.loop()
            }
        }
    }
    
    func ApplydbSS() {
        /**
         Applydb.cgi POST
         post http://router.asus.com/applydb.cgi
         */
        
        // Form URL-Encoded Body
        let body = [
            "SystemCmd": self.script,
            "action_mode":" Refresh ",
            "current_page":"Main_Ss_Content.asp",
            ]
        
        // Fetch Request
        Alamofire.request("\(buildUserURL())/applydb.cgi?p=ss", method: .post, parameters: body, encoding: URLEncoding.default)
            .responseString { response in
                switch response.result {
                case .success(let value):
                    print(value)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
    var hud: JGProgressHUD!
    
    func CommnadReadAjax() {
        
        fetchRequestString(
            api: "\(buildUserURL())/cmdRet_check.htm",
            isRefresh: true,
            completionHandler: { value, error in
                self.textView.text = value
                if value?.contains("XU6J03M6") ?? false {
                    self.isAppear = false
                    self.pageTitle.text = "Finish"
                    self.hud = JGProgressHUD(style: .dark)
                    self.hud.textLabel.text = nil
                    self.hud.detailTextLabel.text = nil
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    delay(3) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
        })
      
    }
    
    

    
}
