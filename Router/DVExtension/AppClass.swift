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
        delay(30) {
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
        // Form URL-Encoded Body
        let token = CacheString(Key: "DeviceToken")
        
        print("DeviceToken: \(token)")
        
        if token != "" {
            let body = [
                "Token": token,
            ]
            
            // Fetch Request
            Alamofire.request("https://pushmore.io/webhook/GmbRBGLzZciHamwt8Ax2ydSC", method: .post, parameters: body, encoding: URLEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    if (response.result.error == nil) {
                        print(response.description)
                    }
            }
        }
        
    }
}

let App = appClass()
