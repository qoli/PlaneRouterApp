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
import Chrysan
import Localize_Swift

class CommnadRead_ViewController: UIViewController {

    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var textView: UITextView!

    // MARK: - page view

    var isAppear = true
    var script = "ss_config.sh"
    var params = "start"
    var ssLinks: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        ApplydbSS()
    }

    override func viewWillAppear(_ animated: Bool) {
        isAppear = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        isAppear = false
    }

    // MARK: - close

    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func returnToRoot() {
        var rootVC = self.presentingViewController
        while let parent = rootVC?.presentingViewController {
            rootVC = parent
        }
        //释放所有下级视图
        NotificationCenter.default.post(name: NSNotification.Name.init("collectionSelect"), object: 1)
        NotificationCenter.default.post(name: NSNotification.Name.init("ConnectViewonShow"), object: true)
        App.appDataNeedUpdate(isUpdate: true)
        rootVC?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Loop

    func LoopLoadText() {
        self.CommnadReadAjax()
        delay(2) {
            if self.isAppear {
                self.LoopLoadText()
            }
        }
    }

    // MARK: Apply Page

    func ApplydbSS() {

        print("applyPost: \(buildUserURL())/\(ModelPage.ApplyPost)")

        switch ModelPage.runningModel {
        case .arm:

            var body: [String: String]?

            if self.ssLinks != "" {
                // add link
                body = [
                    "SystemCmd": self.script,
                    "action_mode": " Refresh ",
                    "current_page": "Main_Ss_Content.asp",
                    "ss_base64_links": "\(self.ssLinks)",
                ]
            } else {
                // normal
                body = [
                    "SystemCmd": self.script,
                    "action_mode": " Refresh ",
                    "current_page": "Main_Ss_Content.asp",
                ]
            }

            // Fetch Request
            Alamofire.request("\(buildUserURL())/\(ModelPage.ApplyPost)", method: .post, parameters: body, encoding: URLEncoding.default)
                .responseString { response in
                    switch response.result {
                    case .success(_):
                        self.LoopLoadText()
                    case .failure(let error):
                        self.chrysan.show(.error, message: error.localizedDescription, hideDelay: 1)
                    }
            }


        case .hnd:

            var body: [String: Any]?
            if self.ssLinks == "" {
                // normal
                body = [
                    "fields": [],
                    "id": 95131455,
                    "method": script,
                    "params": [
                        self.params
                    ]
                ]
            } else {
                // add link
                body = [
                    "fields": [
                        "ss_base64_links": "\(self.ssLinks)"
                    ],
                    "id": 95131455,
                    "method": script,
                    "params": [
                        4
                    ]
                ]
            }



            // Fetch Request
            Alamofire.request("\(buildUserURL())/\(ModelPage.ApplyPost)", method: .post, parameters: body, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    if (response.result.error == nil) {
                        self.LoopLoadText()
                    }
                    else {
                        self.chrysan.show(.error, message: response.result.error?.localizedDescription, hideDelay: 1)
                    }
            }
        }
    }


    func CommnadReadAjax() {
        let timestamp = Date().timeIntervalSince1970

        fetchRequestString(
            api: "\(buildUserURL())/\(ModelPage.Log)?_=\(Int(timestamp))",
            isRefresh: true,
            completionHandler: { value, error in
                self.textView.text = value
                delay {
                    let textViewBottom = NSMakeRange(self.textView.text.count - 1, 1)
                    self.textView.scrollRangeToVisible(textViewBottom)
                    self.textView.isScrollEnabled = false
                    self.textView.isScrollEnabled = true
                }

                if value?.contains("XU6J03M6") ?? false {
                    self.isAppear = false
                    self.pageTitle.text = "Finish".localized()
                    self.chrysan.show(.succeed, hideDelay: 1)
                    delay(2) {
                        self.returnToRoot()
                    }
                }
            })

    }




}
