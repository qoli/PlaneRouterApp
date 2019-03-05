//
//  NetRequest.swift
//  Router
//
//  Created by 庫倪 on 2019/2/18.
//  Copyright © 2019 庫倪. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

// MARK: Get Cookie

func GetRouterCookie() {
    /**
     GetRouterCookie
     post http://router.asus.com/login.cgi
     */

    // user
    
    let uConfig = getUserConfig(name: "Router")
    print(uConfig)
    let auth: String = (uConfig.loginName) + ":" + (uConfig.loginPassword)
        
    // Add Headers
    let headers = [
        "Referer": "http://router.asus.com/",
        "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
    ]

    // Form URL-Encoded Body
    let body = [
        "login_authorization": "\(auth.base64Encoded() ?? "")",
    ]

    // auth
    if auth != ":" {
        // Fetch Request
        Alamofire.request("http://router.asus.com/login.cgi", method: .post, parameters: body, encoding: URLEncoding.default, headers: headers)
            .responseString { response in
                if (response.result.error == nil) {
                    print("login...")
                }
        }
    } else {
        print("Settings not found")
    }
}


// MARK: - SS Data

func updateSSData(isRefresh: Bool = false, completionHandler: @escaping ([String: String], Error?) -> Void) {

    let returnCommand = SSHRun(command: "dbus list ss", cacheKey: "ssDataCommand", isRefresh: isRefresh, isRouter: true)
    
    let rLines = returnCommand.lines
    var dataDict: [String: String] = [:]
    
    for line in rLines {
        let data = line.groups(for: "(.*?)=(.*?)$")
        if data != [] {
            if data[0].count == 3 {
                dataDict["\(data[0][1])"] = "\(data[0][2])"
            }
        }
        
    }
    
    UserDefaults.standard.set(dataDict, forKey: "ssData")
    completionHandler(dataDict, nil)
    
}

// MARK: get data & cache

func fetchRequest(api: String, isRefresh: Bool = false, completionHandler: @escaping (NSDictionary?, Error?) -> Void) {
    
    var cacheObject = UserDefaults.standard.object(forKey: api)
    
    if isRefresh == true {
        cacheObject = nil
    }
    
    if cacheObject != nil {
        print("\(api) [onCache]")
        completionHandler(cacheObject as? NSDictionary, nil)
        
    } else {
        print("\(api) [request]")
        Alamofire.request(api, method: .get)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    UserDefaults.standard.set(value, forKey: api)
                    completionHandler(value as? NSDictionary, nil)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    completionHandler(nil, error)
                }
        }
    }
    
}

func fetchRequestString(api: String, isRefresh: Bool = false, completionHandler: @escaping (String?, Error?) -> Void) {
    let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
    
    var cacheObject = UserDefaults.standard.object(forKey: api)
    
    if isRefresh == true {
        cacheObject = nil
    }
    
    if cacheObject != nil {
        print("\(api) [onCache]")
        completionHandler(cacheObject as? String, nil)
    } else {
        print("\(api) [request]")
        Alamofire.request(api, method: .get)
            .responseString(queue: queue, encoding: String.Encoding.utf8) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let value):
                        if !value.hasPrefix("<HTML><HEAD><script>top.location.href='/Main_Login.asp';</script>") {
                            UserDefaults.standard.set(value, forKey: api)
                            completionHandler(value, nil)
                        } else {
                            print("fetchRequestString [need login]")
                            completionHandler(nil, nil)
                        }
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        completionHandler(nil, error)
                    }
                }
        }
    }
    
}
