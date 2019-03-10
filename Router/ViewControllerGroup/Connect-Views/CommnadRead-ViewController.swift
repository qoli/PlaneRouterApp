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
    var params = "\"start\""
    
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
        rootVC?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Loop
    
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
        ModelPage.scriptName = self.script
        ModelPage.params = self.params
        
        
        print("applyPost: \(buildUserURL())/\(ModelPage.ApplyPost)")
        
        switch ModelPage.runningModel {
        case .arm:
            
            // Form URL-Encoded Body
            let body = [
                "SystemCmd": ModelPage.scriptName,
                "action_mode":" Refresh ",
                "current_page":"Main_Ss_Content.asp",
                ]
            
            // Fetch Request
            Alamofire.request("\(buildUserURL())/\(ModelPage.ApplyPost)", method: .post, parameters: body, encoding: URLEncoding.default)
                .responseString { response in
                    switch response.result {
                    case .success(let value):
                        print(value)
                        self.LoopLoadText()
                    case .failure(let error):
                        print("Apply POST: ",error.localizedDescription)
                    }
            }
            
            
        case .hnd:
            
            // Custom Body Encoding
            struct RawDataEncoding: ParameterEncoding {
                public static var `default`: RawDataEncoding { return RawDataEncoding() }
                public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                    var request = try urlRequest.asURLRequest()
                    //let timestamp = Date().timeIntervalSince1970
                    let body = "{\"id\":10001,\"method\":\"\(ModelPage.scriptName)\",\"params\":[\(ModelPage.params)],\"fields\":{}}"
                    request.httpBody = body.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    print(body)
                    return request
                }
            }
            
            // Fetch Request
            Alamofire.request("\(buildUserURL())/\(ModelPage.ApplyPost)", method: .post, encoding: RawDataEncoding.default)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        print(value)
                        self.LoopLoadText()
                    case .failure(let error):
                        print("Apply POST: ",error.localizedDescription)
                    }
            }
        }
    }
    
    var hud: JGProgressHUD!
    
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
                    self.pageTitle.text = "Finish"
                    self.hud = JGProgressHUD(style: .dark)
                    self.hud.textLabel.text = nil
                    self.hud.detailTextLabel.text = nil
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    delay(3) {
                        self.returnToRoot()
                    }
                }
        })
      
    }
    
    

    
}
