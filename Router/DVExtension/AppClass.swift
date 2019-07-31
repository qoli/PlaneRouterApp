//
//  APPClass.swift
//  Router
//
//  Created by 庫倪 on 2019/3/29.
//  Copyright © 2019 庫倪. All rights reserved.
//

import Foundation
import Alamofire

class appClass {
    // MARK: - var
    
    var appListON: Bool = true
    var appDataneedUpdate = false
    
    func appDataSetNeedUpdate(isUpdate: Bool = false) {
        self.appDataneedUpdate = isUpdate
        delay(15) {
            self.appDataneedUpdate = false
        }
    }
    
    func appDatadoUpdate() -> Bool {
        if self.appDataneedUpdate {
            self.appDataneedUpdate = false
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Post User Token
    func PostToken() {
        var token = CacheString(Key: "DeviceToken")
        
        let model: String = SSHRun(command: "nvram get model", cacheKey: "nvramGetModel")
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let versionText = "Version \(appVersion ?? "1.0") Build \(buildNumber ?? "0")"
        
        if token == "" {
            token = "空白或模擬器"
        }
        
        self.sendMessage(type: "\(model.removingWhitespacesAndNewlines)", title: versionText, text: token)
    }
    
    func sendMessage(type: String, title: String, text: String) {
        let urlParams = [
            "text":"[Router App]\n\r- \(type) \n\r- \(title) \n\r- \(text)"
        ]
        Alamofire.request("https://tgbot.lbyczf.com/sendMessage/9qvmshonjxf5csk5", method: .get, parameters: urlParams)
    }
}

let App = appClass()
