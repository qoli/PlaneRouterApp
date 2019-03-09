//
//  AppFunction.swift
//  Router
//
//  Created by 庫倪 on 2019/2/9.
//  Copyright © 2019 庫倪. All rights reserved.
//

import Foundation
import NMSSH
import Alamofire
import SwiftyJSON
import NotificationBannerSwift

struct Host {
    static var domain = "router.asus.com"
}

// MARK: app service list

func addServiceList(serviceName: String) {
    let cacheKey = "com.qoli.ServiceList"
    var cacheResult = UserDefaults.standard.array(forKey: cacheKey)
    if cacheResult == nil {
        cacheResult = []
    }
    cacheResult?.append(serviceName)

    if serviceName == "" {
        cacheResult = []
    }

    UserDefaults.standard.set(cacheResult, forKey: cacheKey)
}

func getServiceList() -> Array<Any> {
    let cacheKey = "com.qoli.ServiceList"
    let cacheResult = UserDefaults.standard.array(forKey: cacheKey)
    return cacheResult ?? []
}

// MARK: run in ssh

func SSHRun(command: String, cacheKey: String = "", isRefresh: Bool = false, isRouter: Bool = true, isShowResponse: Bool = false) -> String {

    var isR = isRefresh

    var host: String!
    var username: String!
    var password: String!

    if isRouter {
        let uConfig = getUserConfig(name: "Router")
        host = uConfig.address
        username = uConfig.loginName
        password = uConfig.loginPassword
    } else {
        host = UserDefaults.standard.string(forKey: "serverAddress")
        username = UserDefaults.standard.string(forKey: "serverUser")
        password = UserDefaults.standard.string(forKey: "serverPass")
    }

    if cacheKey == "" {
        isR = true
    }

    if host == nil {
        return "Host nil"
    } else {
        if isR == true {
            let session = NMSSHSession(host: host ?? "", andUsername: username ?? "")
            session.connect()
            if session.isConnected {
                session.authenticate(byPassword: password ?? "")
                let response = session.channel.execute(command, error: nil)
                
                if isShowResponse {
                    print("[SSHRun] isRouter: \(isRouter), command: \(command), response: \(response)")
                } else {
                    print("[SSHRun] isRouter: \(isRouter), command: \(command)")
                }
                
                return CacheString(text: response, Key: cacheKey)
            }
            session.disconnect()
            return "null"
        } else {
            let cacheText = CacheString(Key: cacheKey)
            if cacheText == "" {
                _ = SSHRun(command: command, cacheKey: cacheKey, isRefresh: true)
            }
            return cacheText
        }
    }

}

// MARK: cache

func CacheString(text: String = "", Key: String) -> String {
    if text == "" {
        return UserDefaults.standard.string(forKey: "com.qoli.\(Key)") ?? ""
    } else {
        UserDefaults.standard.set(text, forKey: "com.qoli.\(Key)")
        return text
    }
}



// MARK: 十六进制转十进制
func hexTodec(number num: String) -> Double {
    let str = num.uppercased()
    var sum = 0
    for i in str.utf8 {
        sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
        if i >= 65 { // A-Z 从65开始，但有初始值10，所以应该是减去55
            sum -= 7
        }
    }
    return Double(sum)
}

// MARK: delay

func delay(_ delay: Double = 0.2, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure
    )
}

// MARK: Message

func messageNotification(message: String, title: String = "Plane Router App") {
    let banner = NotificationBanner(title: title, subtitle: message, style: .info)
    banner.duration = 0.6
    banner.dismiss()
    banner.show()
}
