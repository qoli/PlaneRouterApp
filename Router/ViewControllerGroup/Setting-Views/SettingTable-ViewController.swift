//
//  SettingTable-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/24.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero

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
            self.name.layer.opacity = 0.4
            delay(0.8) {
                self.name.layer.opacity = 1
            }
        }
    }
}

class settingADDCell: UITableViewCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
}

class settingRowCell: UITableViewCell {
    @IBOutlet weak var row: UILabel!
    @IBOutlet weak var imageRow: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        
        if selected {
            self.row.layer.opacity = 0.4
            delay(0.8) {
                self.row.layer.opacity = 1
            }
        }
    }
}

class SettingTable_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var pageTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // hero
        pageTitle.hero.modifiers = [.fade, .translate(x: -25)]
        
        //UserDefaults.standard.set(false, forKey: "isApp")
        
        // table
        table_init()
    }

    // table

    // https://t.me/planeroutapp

    let rowSetting1: [String] = [
        "Title",
        "RouterSSH#Router"
    ]

    let rowSetting2: [String] = [
        "Add",
        "Title",
        "Row",
        "Row",
        "Row"
    ]

    var configSSH: [String] = [
        "Hosts",
        "Router SSH"
    ]

    var rowSetting: [String]!

    var configNew: [String]?

    var settingData: [String] = [
        "",
        "Setting",
        "How to open Router SSH",
        "Check Tutorials again",
        "Clean up local storage"
    ]

    var tableData: [String]!

    @IBOutlet weak var tableView: UITableView!

    func table_init() {

        if configNew?.isEmpty ?? true {
            tableData = configSSH + settingData
            rowSetting = rowSetting1 + rowSetting2
        } else {
            tableData = configSSH + configNew! + settingData
            rowSetting = rowSetting1 + configNew! + rowSetting2
        }

        print(tableData)

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        switch self.rowSetting[indexPath.row] {
        case "Title":
            let cell = tableView.dequeueReusableCell(withIdentifier: "title") as! settingTitleCell
            cell.title.text = tableData[indexPath.row]
            return cell
        case "Row":
            let cell = tableView.dequeueReusableCell(withIdentifier: "row") as! settingRowCell
            cell.row.text = tableData[indexPath.row]
            return cell
        case "Add":
            let cell = tableView.dequeueReusableCell(withIdentifier: "add") as! settingADDCell
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ssh") as! settingSSHCell
            cell.name.text = tableData[indexPath.row]
            return cell

        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch self.rowSetting[indexPath.row] {
        case "RouterSSH":
            self.performSegue(withIdentifier: "goHostsSegue", sender: nil)
        case "Add":
            self.performSegue(withIdentifier: "goHostsSegue", sender: nil)
        default:
            print(self.rowSetting[indexPath.row])
            
        }
        
    }

}
