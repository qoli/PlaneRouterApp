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

// MARK: Model Page Setting
// hnd: logPage:"_temp/ss_log.txt" PostPage:"_api/"

class modelPageClass {
    var ApplyPost: String = "applydb.cgi?p=ss"
    var Log: String = "cmdRet_check.htm"
    var Status: String = "ss_status"

    var runningModel = model.arm

    enum model {
        case arm
        case hnd
    }

    func updateStatus() {
        switch ModelPage.runningModel {
        case .arm:
            print("Model: ARM")
        case .hnd:
            print("Model: HND")
        }
    }

    func setModel(model: model) {
        switch model {
        case .arm:
            ApplyPost = "applydb.cgi?p=ss"
            Log = "cmdRet_check.htm"
            Status = "ss_status"
            runningModel = .arm
            print("Model: ARM")
        case .hnd:
            ApplyPost = "_api/"
            Log = "_temp/ss_log.txt"
            Status = "_result/9527"
            runningModel = .hnd
            print("Model: HND")
        }
    }

    func autoSetModel() {
        let model: String = SSHRun(command: "nvram get model")

        switch model {
        case "RT-AC86U\n":
            setModel(model: .hnd)
        case "GT-AC5300\n":
            setModel(model: .hnd)
        default:
            setModel(model: .arm)
        }
    }
}

// MARK: Get Cookie

let ModelPage = modelPageClass()

func GetRouterCookie(name: String = "", pass: String = "") {
    /**
     GetRouterCookie
     post http://router.asus.com/login.cgi
     */

    // user
    var auth: String?
    let uConfig = getUserConfig(name: "Router")

    if name != "" {
        auth = (name) + ":" + (pass)
    } else {
        auth = (uConfig.loginName) + ":" + (uConfig.loginPassword)
    }


    // Add Headers
    let headers = [
        "Referer": "\(buildUserURL())/index.asp",
        "Content-Type": "application/x-www-form-urlencoded; charset=utf-8"
    ]

    // Form URL-Encoded Body
    let body = [
        "login_authorization": "\(auth?.base64Encoded() ?? "")",
    ]

    // auth
    if auth != ":" {
        // Fetch Request
        Alamofire.request("\(buildUserURL())/login.cgi", method: .post, parameters: body, encoding: URLEncoding.default, headers: headers)
            .responseString { response in
                if (response.result.error == nil) {
                    if name != "" {
                        print("login...by", name)
                    } else {
                        print("login...by", uConfig)
                    }
                    //
                    ModelPage.autoSetModel()
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

// MARK: Fetch Request

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
                    print("\(api) [\(error.localizedDescription)]")
                    completionHandler(nil, error)
                }
        }
    }

}

func fetchRequestString(api: String, isRefresh: Bool = false, completionHandler: @escaping (String?, Error?) -> Void) {
    var cacheObject = UserDefaults.standard.object(forKey: api)

    if isRefresh == true {
        cacheObject = nil
    }

    if cacheObject != nil {
        print("\(api) [onCache]")
        completionHandler(cacheObject as? String, nil)
    } else {
        print("\(api) [request]")

        let headers = [
            "Referer": "http://router.asus.com/index.asp"
        ]


        Alamofire.request(api, method: .get, headers: headers)
            .responseString(encoding: String.Encoding.utf8) { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let value):
                        if !value.hasPrefix("<HTML><HEAD><script>top.location.href='/Main_Login.asp';</script>") {
                            UserDefaults.standard.set(value, forKey: api)
                            completionHandler(value, nil)
                        } else {
                            print("fetchRequestString \(api) [need login]")
                            messageNotification(message: "Need Router Login")
                            completionHandler(nil, nil)
                        }

                    case .failure(let error):
                        print("\(api) [\(error.localizedDescription)]")
                        completionHandler(nil, error)
                    }
                }
        }
    }

}
