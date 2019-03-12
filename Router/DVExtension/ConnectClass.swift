//
//  ConnectClass.swift
//  Router
//
//  Created by 庫倪 on 2019/3/13.
//  Copyright © 2019 庫倪. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class connectClass {

    // MARK: - 數據結構

    enum connectMode: String {
        case http = "http"
        case https = "https"
        case ssh = "ssh"
        case none = "none"
    }

    struct ConnectStruct {
        var identifier: String
        var name: String
        var mode: connectMode
        var address: String
        var port: Int64
        var loginName: String
        var loginPassword: String
        var type: serviceListClass.connectTypeEnum
        
        init(identifier: String, name: String, mode: connectMode, address: String, port: Int64, loginName: String, loginPassword: String, type: serviceListClass.connectTypeEnum) {
            self.identifier = identifier
            self.name = name
            self.mode = mode
            self.address = address
            self.port = port
            self.loginName = loginName
            self.loginPassword = loginPassword
            self.type = type
        }
    }
    
    struct ConnectJSON: Codable {
        var identifier: String
        var name: String
        var mode: String
        var address: String
        var port: Int64
        var loginName: String
        var loginPassword: String
        var type: String
        
        init(identifier: String, name: String, mode: String, address: String, port: Int64, loginName: String, loginPassword: String, type: String) {
            self.identifier = identifier
            self.name = name
            self.mode = mode
            self.address = address
            self.port = port
            self.loginName = loginName
            self.loginPassword = loginPassword
            self.type = type
        }
    }

    // MARK: - Entity Name

    let entityName: String = "ConnectData"

    var context: NSManagedObjectContext!
    var entity: NSEntityDescription!

    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        self.context = appDelegate.persistentContainer.viewContext
        self.entity = NSEntityDescription.entity(forEntityName: self.entityName, in: self.context)!
    }

    func buildConnectConfig(name: String, mode: connectMode, address: String, port: Int64, loginName: String, loginPassword: String, type: serviceListClass.connectTypeEnum) -> ConnectStruct {
        let uuid = NSUUID().uuidString
        let config = ConnectStruct(identifier: uuid, name: name, mode: mode, address: address, port: port, loginName: loginName, loginPassword: loginPassword, type: type)
        _ = self.save(connect: config)
        return config
    }

    func routerConfig(mode: connectMode, address: String, port: Int64, loginName: String, loginPassword: String, type: serviceListClass.connectTypeEnum) -> ConnectStruct {

        let uuid = "RouterConfig"
        let name = "Router"
        let config = ConnectStruct(identifier: uuid, name: name, mode: mode, address: address, port: port, loginName: loginName, loginPassword: loginPassword, type: type)

        if getRouter().identifier == "" {
            _ = self.save(connect: config)
        } else {
            self.updateConnectConfig(connect: config)
        }


        return config
    }

    func save(connect: ConnectStruct) -> (Bool, String) {
        let saveObject = NSManagedObject(entity: self.entity, insertInto: self.context)

        // set
        saveObject.setValue(connect.identifier, forKey: "identifier")

        saveObject.setValue(connect.name, forKey: "name")
        saveObject.setValue(connect.address, forKeyPath: "address")
        saveObject.setValue(connect.mode.rawValue, forKeyPath: "mode")
        saveObject.setValue(connect.port, forKey: "port")
        saveObject.setValue(connect.loginName, forKeyPath: "loginName")
        saveObject.setValue(connect.loginPassword, forKeyPath: "loginPassword")
        saveObject.setValue(connect.type.rawValue, forKeyPath: "type")

        // save
        do {
            try self.context.save()
            return (true, "")
        } catch let error as NSError {
            print("Save Failed. \(error), \(error.userInfo)")
            return (false, error.localizedDescription)
        }
    }

    func getAll() -> [ConnectStruct] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        var returnDate: [ConnectStruct] = []

        do {
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let r = ConnectStruct.init(
                    identifier: data.value(forKey: "identifier") as! String,
                    name: data.value(forKey: "name") as! String,
                    mode: connectMode(rawValue: data.value(forKey: "mode") as! String) ?? connectMode.none,
                    address: data.value(forKey: "address") as! String,
                    port: data.value(forKey: "port") as! Int64,
                    loginName: data.value(forKey: "loginName") as! String,
                    loginPassword: data.value(forKey: "loginPassword") as! String,
                    type: serviceListClass.connectTypeEnum(rawValue: data.value(forKey: "type") as! String) ?? serviceListClass.connectTypeEnum.Router)
                returnDate.append(r)
            }
            return returnDate
        } catch {
            print("fetchRequest Failed")
            return []
        }
    }

    func getRouter() -> ConnectStruct {
        let one = ConnectStruct(identifier: "", name: "", mode: .none, address: "", port: 0, loginName: "", loginPassword: "", type: .Router)
        var returnDate: ConnectStruct?
        let result = self.getAll()
        for data in result {
            if data.identifier == "RouterConfig" {
                returnDate = data
            }
        }
        return returnDate ?? one
    }

    func getByID(identifier: String) -> ConnectStruct {
        let one = ConnectStruct(identifier: "", name: "", mode: .none, address: "", port: 0, loginName: "", loginPassword: "", type: .Server)
        var returnDate: ConnectStruct?
        let result = self.getAll()
        for data in result {
            if data.identifier == identifier {
                returnDate = data
            }
        }
        return returnDate ?? one
    }
    
    func getAllJSON() -> [String] {
        
        var returnData: [String] = []
        
        let data = self.getAll()
        
        for d in data {
            do {
                
                let jsonConfig = ConnectJSON(identifier: d.identifier, name: d.name, mode: d.mode.rawValue, address: d.address, port: d.port, loginName: d.loginName, loginPassword: d.loginPassword, type: d.type.rawValue)
                
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(jsonConfig)
                let jsonString = String(data: jsonData, encoding: .utf8)
                returnData.append(jsonString ?? "")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return returnData
        
    }

    func remove(identifier: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        if let result = try? context.fetch(fetchRequest) {
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "identifier") as! String == identifier {
                    context.delete(data)
                }
            }
        }
    }

    func updateConnectConfig(connect: ConnectStruct) {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "identifier") as! String == connect.identifier {
                    data.setValue(connect.identifier, forKey: "identifier")

                    data.setValue(connect.name, forKey: "name")
                    data.setValue(connect.address, forKeyPath: "address")
                    data.setValue(connect.mode.rawValue, forKeyPath: "mode")
                    data.setValue(connect.port, forKey: "port")
                    data.setValue(connect.loginName, forKeyPath: "loginName")
                    data.setValue(connect.loginPassword, forKeyPath: "loginPassword")
                    data.setValue(connect.type.rawValue, forKeyPath: "type")
                    // save
                    do {
                        try self.context.save()
                        print("Update Done")
                    } catch let error as NSError {
                        print("Update Failed \(error), \(error.userInfo)")
                    }
                }

            }
        } catch {
            print("Fetch Failed")
        }
    }

}

let ConnectConfig = connectClass()

func buildUserURL(identifier: String = "RouterConfig") -> String {
    let r = ConnectConfig.getByID(identifier: identifier)
    if r.identifier == "" {
        return "http://router.asus.com"
    } else {
        return "\(r.mode)://\(r.address):\(r.port)"
    }

}
