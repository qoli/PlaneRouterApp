//
//  userConfig.swift
//  Router
//
//  Created by 庫倪 on 2019/3/5.
//  Copyright © 2019 庫倪. All rights reserved.
//

import Foundation
import SwiftyJSON

struct userConfig: Codable {
    var name: String
    var mode: String
    var address: String
    var port: Int
    var loginName: String
    var loginPassword: String

    init(name: String, mode: String, address: String, port: Int, loginName: String, loginPassword: String) {
        self.name = name
        self.mode = mode
        self.address = address
        self.port = port
        self.loginName = loginName
        self.loginPassword = loginPassword
    }
}

let userConfigCacheKey = "com.qoli.userConfigCacheKey"

func buildUserURL(name: String = "Router") -> String {
    let r = getUserConfig(name: name)    
    return "\(r.mode)://\(r.address):\(r.port)"
}

func saveUserConfig(userConfig: userConfig) -> (Bool, String) {
    var isUpdate = false
    let r = getUserConfig(name: userConfig.name)
    if r.name != "" {
        isUpdate = true
        _ = getUserConfig(name: userConfig.name, isRemove: true)
    }

    var userConfigJSONArray:[String] = UserDefaults.standard.array(forKey: userConfigCacheKey) as? [String] ?? []
    do {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(userConfig)
        let jsonString = String(data: jsonData, encoding: .utf8)
        userConfigJSONArray.append(jsonString ?? "")
        UserDefaults.standard.set(userConfigJSONArray, forKey: userConfigCacheKey)
        if isUpdate {
            return (true,"update")
        } else {
            return (true,"successful")
        }
        
    } catch {
        return (false,error.localizedDescription)
    }
}

func getUserConfig(name: String, isRemove: Bool = false) -> userConfig {
    let emptyOne = userConfig(name: "", mode: "", address: "", port: 0, loginName: "", loginPassword: "")
    var userConfigJSONArray:[String] = UserDefaults.standard.array(forKey: userConfigCacheKey) as? [String] ?? []
    var returnOne:userConfig?
    var i = 0
    for u in userConfigJSONArray {
        if let data = u.data(using: .utf8) {
            if let json = try? JSON(data: data) {
                if name == json["name"].stringValue {
                    if isRemove {
                        if i <= userConfigJSONArray.count {
                            userConfigJSONArray.remove(at: i)
                        }
                        UserDefaults.standard.set(userConfigJSONArray, forKey: userConfigCacheKey)
                    }
                    
                    returnOne = userConfig(
                        name: json["name"].stringValue,
                        mode: json["mode"].stringValue,
                        address: json["address"].stringValue,
                        port: json["port"].intValue,
                        loginName: json["loginName"].stringValue,
                        loginPassword: json["loginPassword"].stringValue)
                }
            }
        }
        i = i + 1
    }
    
    return returnOne ?? emptyOne
}

func getAllUserConfig() -> [String] {
    return UserDefaults.standard.array(forKey: userConfigCacheKey) as? [String] ?? []
}
