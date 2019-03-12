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

// MARK: - run in ssh

func SSHRun(command: String, cacheKey: String = "", isRefresh: Bool = false, isRouter: Bool = true, isShowResponse: Bool = false, isTest: Bool = false) -> String {

    if isTest {
        print("[SSHRun] not Run: \(command)")
        return ""
    }

    var isR = isRefresh

    var host: String!
    var username: String!
    var password: String!

    if isRouter {
        let uConfig = ConnectConfig.getRouter()
        host = uConfig.address
        username = uConfig.loginName
        password = uConfig.loginPassword
    } else {
        host = UserDefaults.standard.string(forKey: "serverAddress")
        username = UserDefaults.standard.string(forKey: "serverUser")
        password = UserDefaults.standard.string(forKey: "serverPass")
    }

    if cacheKey == "" || getCacheBool(Key: "isUpdate") {
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
                    print("[SSHRun] isRouter: \(isRouter), command: \(command), response: \(response), isR: \(isR) [SSH]")
                } else {
                    print("[SSHRun] isRouter: \(isRouter), command: \(command), isR: \(isR)  [SSH]")
                }

                return CacheString(text: response, Key: cacheKey)
            }
            session.disconnect()
            return "null"
        } else {
            let cacheText = CacheString(Key: cacheKey)
            if cacheText == "" {
                _ = SSHRun(command: command, cacheKey: cacheKey, isRefresh: true)
            } else {
                print("[SSHRun] isRouter: \(isRouter), command: \(command) [onCache]")
            }
            return cacheText
        }
    }

}

// MARK: - cache

func CacheString(text: String = "", Key: String) -> String {
    if text == "" {
        return UserDefaults.standard.string(forKey: "com.qoli.\(Key)") ?? ""
    } else {
        UserDefaults.standard.set(text, forKey: "com.qoli.\(Key)")
        return text
    }
}

func setCacheBool(value: Bool, Key: String) {
    UserDefaults.standard.set(value, forKey: Key)
}

func getCacheBool(Key: String) -> Bool{
    return UserDefaults.standard.bool(forKey: Key)
}


// MARK: - 十六进制转十进制
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

// MARK: - delay

func delay(_ delay: Double = 0.2, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure
    )
}

// MARK: - UI

func messageNotification(message: String, title: String = "Plane Router App") {
    let banner = NotificationBanner(title: title, subtitle: message, style: .info)
    banner.duration = 2
    banner.dismiss()
    banner.show()
}

// MARK: animate

func buttonTapAnimate(button: UIButton) {
    UIView.animate(
        withDuration: 0.1,
        animations: {
            button.alpha = 0.3
        },
        completion: { _ in
            UIView.animate(withDuration: 0.6, animations: {
                button.alpha = 1
            })
        })
}

func getCurrentLanguage() -> String {
    let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
    print("当前系统语言:\(preferredLang)")
    
    switch String(describing: preferredLang) {
    case "en-US", "en-CN":
        return "en"//英文
    case "zh-Hans-US","zh-Hans-CN","zh-Hans":
        return "sc"//中文
    case "zh-TW","zh-HK","zh-Hant","zh-Hant-CN":
        return "tc"//中文
    default:
        return "en"
    }
}

let OSLanguage = getCurrentLanguage()
