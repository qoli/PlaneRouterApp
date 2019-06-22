//
//  APPClass.swift
//  Router
//
//  Created by 庫倪 on 2019/3/29.
//  Copyright © 2019 庫倪. All rights reserved.
//

import Foundation

class appClass {
    // MARK: - var
    
    var appListON: Bool = true
    var appDataneedUpdate = false
    
    func appDataNeedUpdate(isUpdate: Bool = false) {
        self.appDataneedUpdate = isUpdate
        delay(3) {
            self.appDataneedUpdate = false
        }
    }
}

let App = appClass()
