//
//  SettingTable-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/24.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import SwiftyJSON

class settingTitleCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
}

class settingSSHCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        
        if selected {
            self.layer.opacity = 0.3
            delay {
                self.layer.opacity = 1
            }
        }
    }
}

class settingADDCell: UITableViewCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        
        if selected {
            self.layer.opacity = 0.3
            delay {
                self.layer.opacity = 1
            }
        }
    }
}

class settingRowCell: UITableViewCell {
    @IBOutlet weak var row: UILabel!
    @IBOutlet weak var imageRow: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        
        if selected {
            self.layer.opacity = 0.3
            delay {
                self.layer.opacity = 1
            }
        }
    }
}

class SettingTable_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var pageTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        print("SettingTable_ViewController: viewDidLoad")
        
        // hero
        pageTitle.hero.modifiers = [.fade, .translate(x: -25)]
        
        // table
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        table_update()
    }
    
    // MARK: - Segue
    
    var isAdd: Bool = true
    var isRouter: Bool = false
    var configName: String = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goSettingDetailSegue" {
            if let destinationVC = segue.destination as? SettingDetail_ViewController {
                destinationVC.isAdd = self.isAdd
                destinationVC.isRouter = self.isRouter
                destinationVC.name = self.configName
            }
        }
    }
    
    // MARK: - load data

    func loadJSONFile() {
        if let path = Bundle.main.path(forResource: "setting", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try JSON(data: data)
                tableJSON = json
            } catch {
                print("parse error: \(error.localizedDescription)")
            }
        }
    }
    
    func loadUserConfig() {
        userJSON = []
        let uConfig = getAllUserConfig()
        let userData = uConfig
        for u in userData {
            if let data = u.data(using: .utf8) {
                if let json = try? JSON(data: data) {
                    userJSON.append(json)
                }
            }
        }
    }
    
    //MARK: - table

    var userJSON:[JSON] = []
    var tableJSON:JSON!
    var tableArray:[Any] = []
    var tableData:JSON!
    
    @IBOutlet weak var tableView: UITableView!
    
    func table_update() {
        loadJSONFile()
        loadUserConfig()
        
        tableArray = tableJSON["dataTop"].arrayValue + userJSON + tableJSON["dataBottom"].arrayValue
        tableData = JSON(tableArray)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.tableData[indexPath.row]["type"].stringValue {
        case "title":
            let cell = tableView.dequeueReusableCell(withIdentifier: "title") as! settingTitleCell
            cell.title.text = self.tableData[indexPath.row]["title"].stringValue
            return cell
        case "row":
            let cell = tableView.dequeueReusableCell(withIdentifier: "row") as! settingRowCell
            cell.row.text = self.tableData[indexPath.row]["title"].stringValue
            return cell
        case "add":
            let cell = tableView.dequeueReusableCell(withIdentifier: "add") as! settingADDCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ssh") as! settingSSHCell
            cell.name.text = self.tableData[indexPath.row]["name"].stringValue
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch self.tableData[indexPath.row]["type"].stringValue {
        case "title":
            break
            //
        case "row":
            break
            //
        case "add":
            self.isAdd = true
            self.isRouter = false
            self.performSegue(withIdentifier: "goSettingDetailSegue", sender: nil)
        default:
            self.isAdd = false
            let name = self.tableData[indexPath.row]["name"].stringValue
            if name == "Router" {
                self.isRouter = true
            } else {
                self.isRouter = false
            }
            self.configName = self.tableData[indexPath.row]["name"].stringValue
            self.performSegue(withIdentifier: "goSettingDetailSegue", sender: nil)
            
        }
        
    }

}
