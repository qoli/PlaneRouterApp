//
//  ServiceListClass.swift
//  Router
//
//  Created by 庫倪 on 2019/3/12.
//  Copyright © 2019 庫倪. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - Service List Class

class serviceListClass {

    // MARK: Serice [Stgruct]

    enum connectTypeEnum: String, Codable {
        case Router = "Router"
        case Server = "Server"
    }

    public struct serviceStruct: Codable {
        var identifier: String
        var name: String
        var connectName: String
        var connectType: connectTypeEnum
        var connectID: String
        var date: Date

        init(identifier: String, name: String, connectName: String, connectType: connectTypeEnum, connectID: String, date: Date) {
            self.identifier = identifier
            self.name = name
            self.connectName = connectName
            self.connectType = connectType
            self.date = date
            self.connectID = connectID
        }
    }

    // MARK: Entity Name

    let entityName: String = "ServiceData"

    // MARK: Function

    var context: NSManagedObjectContext!
    var entity: NSEntityDescription!

    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        self.context = appDelegate.persistentContainer.viewContext
        self.entity = NSEntityDescription.entity(forEntityName: self.entityName, in: self.context)!

    }

    func buildFixed(name: String) -> serviceStruct {
        let uuid = NSUUID().uuidString
        let r = serviceStruct(identifier: uuid, name: name, connectName: "RouterConfig", connectType: .Router, connectID: "RouterConfig", date: Date())
        return r
    }

    func addService(service: String, connectType: connectTypeEnum) {

        let uuid = NSUUID().uuidString
        let saveObject = NSManagedObject(entity: self.entity, insertInto: self.context)

        // set
        saveObject.setValue(service, forKeyPath: "name")
        saveObject.setValue(uuid, forKey: "identifier")
        saveObject.setValue(connectType.rawValue, forKey: "connectType")
        saveObject.setValue(Date(), forKey: "date")

        // save
        do {
            try self.context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func getSerivces() -> [serviceStruct] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        var returnDate: [serviceStruct] = []

        do {
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let r = serviceStruct(
                    identifier: data.value(forKey: "identifier") as! String,
                    name: data.value(forKey: "name") as! String,
                    connectName: data.value(forKey: "connectName") as? String ?? "",
                    connectType: connectTypeEnum(rawValue: data.value(forKey: "connectType") as! String)!,
                    connectID: data.value(forKey: "connectID") as? String ?? "",
                    date: data.value(forKey: "date") as! Date)
                returnDate.append(r)
            }
            return returnDate
        } catch {
            print("fetchRequest Failed")
            return []
        }
    }

    func getSerivce(identifier: String) -> serviceStruct? {
        var returnDate: serviceStruct?
        let result = self.getSerivces()
        for data in result {
            if data.identifier == identifier {
                returnDate = data
            }
        }
        return returnDate
    }

    func removeSerice(identifier: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        if let result = try? context.fetch(fetchRequest) {
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "identifier") as! String == identifier {
                    context.delete(data)
                }
            }
        }
    }

    func updateSerivceConnectID(identifier: String, connectID: String) {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "identifier") as! String == identifier {
                    data.setValue(connectID, forKey: "connectID")
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

let ServiceList = serviceListClass()
