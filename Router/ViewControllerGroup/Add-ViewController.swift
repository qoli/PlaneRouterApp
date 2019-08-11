//
//  Add-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/19.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import Alamofire
import SwiftyJSON
import PopMenu

class titleCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
}

class addCell: UITableViewCell {
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var serviceDesc: UILabel!
    @IBOutlet weak var activeImageView: UIImageView!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none

        if selected {
            self.serviceName.textColor = UIColor(named: "mainBlue")
            delay(0.8) {
                self.serviceName.textColor = UIColor(named: "gray29")
            }
        }
    }
}

class Add_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var tableSource: JSON = []

    override func viewDidLoad() {
        super.viewDidLoad()

        //
        self.tableView_init()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAddList(isReload: false)
    }

    func getAddList(isReload: Bool = false) {
        fetchRequest(
            api: "https://raw.githubusercontent.com/qoli/AtomicR/master/app/addList.json",
            isRefresh: isReload,
            completionHandler: { value, error in
                if value != nil {
                    self.tableSource = JSON(value as Any)
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            })
    }

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);

        refreshControl.addTarget(
            self,
            action: #selector(self.handleRefresh(_:)),
            for: UIControl.Event.valueChanged)

        return refreshControl
    }()

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getAddList(isReload: true)
    }

    func tableView_init() {
        tableView.delegate = self
        tableView.dataSource = self

        self.tableView.addSubview(self.refreshControl)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSource["data"].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableSource["data"][indexPath.row]["type"] {
        case "title":
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "title") as! titleCell
            cell.title.text = tableSource["data"][indexPath.row]["title"].stringValue
            return cell
        default:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "addCell") as! addCell
            cell.serviceName.text = tableSource["data"][indexPath.row]["title"].stringValue
            cell.serviceDesc.text = tableSource["data"][indexPath.row]["desc"].stringValue
            return cell
        }
        
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableSource["data"][indexPath.row]["type"] == "list" {
            action(selected: indexPath.row)
        }
    }

    // MARK:  - action
    func action(selected: Int) {
        
        let manager = PopMenuManager.default
        manager.actions = []
        manager.actions.append(PopMenuDefaultAction(
            title: "Active Script",
            image: UIImage(named: "iconFontArrowToBottom24"),
            didSelect: { action in
                delay {
                    ServiceList.addService(service: self.tableSource["data"][selected]["name"].stringValue, connectType: .Server)
                    NotificationCenter.default.post(name: NSNotification.Name.init("updateCollection"), object: nil)
                }
        }))
        manager.present(on: self)
        
    }

}
