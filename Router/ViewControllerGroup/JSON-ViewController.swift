//
//  JSON-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/18.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import Alamofire
import SwiftyJSON
import JGProgressHUD
import PopMenu
import NotificationBannerSwift
import SafariServices

class tableLableCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
}

class tableDataCell: UITableViewCell {
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var label: UILabel!
}

class tableActionCell: UITableViewCell {
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var label: UILabel!
}

class tableLinkCell: UITableViewCell {
    @IBOutlet weak var link: UILabel!
}

class JSON_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    var isReload = false
    var jsonName = "Shadowsock"
    var category = ""
    var passCommand = ""
    var isRouter = true

    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var pageDesc: UILabel!
    @IBOutlet weak var pageButton: UIButton!

    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //添加通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(JSONCall(_:)),
            name: NSNotification.Name(rawValue: "JSONCall"),
            object: nil
        )

        //
        table_init()
        page_init()
    }

    @objc func JSONCall(_ notification: Notification) {
        self.jsonName = notification.object as! String
        page_init()
    }
    
    // MARK: - Page init
    
    func page_init() {
        pageGetSrouce()
        
        if jsonName == "Shadowsock" {
            pageDesc.text = "SSH: Router"
            pageButton.isHidden = true
        } else {
            pageDesc.text = "SSH: ..."
            pageButton.isHidden = false
        }
    }

    @IBAction func pageAction(_ sender: UIButton) {
        // 1. Hidden install category & items
        // 2. switch SSH Config
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let manager = PopMenuManager.default
        manager.actions = []
        manager.actions.append(PopMenuDefaultAction(
            title: "Setup SSH",
            image: UIImage(named: "iconFontPlug"),
            didSelect: { action in
                //
        }))
        manager.actions.append(PopMenuDefaultAction(
            title: "Remove Screen",
            image: UIImage(named: "iconFontEraser"),
            didSelect: { action in
                //
        }))
        manager.present(sourceView: self.pageButton)

    }

    func forceReload() {
        print("ForceReload")
        self.isReload = true
        tableView.reloadData()
        delay(0.6) {
            self.isReload = false
        }
    }

    // MARK: Run command
    func runCommand(indexPath: Int) {

        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        self.passCommand = tableData["data"][indexPath]["action"].stringValue + " \n"
        self.performSegue(withIdentifier: "goTerminalViewandRun", sender: nil)
    }

    // MARK: Segue pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTerminalViewandRun" {
            if let destinationVC = segue.destination as? Terminal_ViewController {
                destinationVC.passCommand = self.passCommand
                destinationVC.category = self.category
            }
        }
    }
    
    // MARK: - Table
    
    var tableData: JSON = []
    
    // MARK: Page Get Srouce
    func pageGetSrouce(isReload: Bool = false) {
        refreshControl.beginRefreshing()
        fetchRequest(
            api: "https://raw.githubusercontent.com/qoli/AtomicR/master/app/source/\(jsonName).json",
            isRefresh: isReload,
            completionHandler: { value, error in
                self.refreshControl.endRefreshing()
                
                if value != nil {
                    self.tableView.isHidden = false
                    self.tableData = JSON(value!)
                    self.pageTitleLabel.text = self.tableData["name"].stringValue
                    self.category = self.tableData["category"].stringValue
                    if self.category == "server" {
                        self.isRouter = false
                    }
                    self.tableView.reloadData()
                } else {
                    self.tableView.isHidden = true
                    self.pageTitleLabel.text = self.jsonName
                    self.errorMessage.text = error?.localizedDescription
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
        pageGetSrouce(isReload: true)
    }

    func table_init() {
        self.tableView.addSubview(self.refreshControl)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 60
    }


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView.contentOffset.y >= 100 {
            NotificationCenter.default.post(name: NSNotification.Name.init("appServiceList"), object: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData["data"].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch tableData["data"][indexPath.row]["type"].stringValue {
        case "status":
            let statusCell = self.tableView.dequeueReusableCell(withIdentifier: "dataCell") as! tableDataCell

            statusCell.value.text = tableData["data"][indexPath.row]["action"].stringValue
            statusCell.label.text = tableData["data"][indexPath.row]["value"].stringValue

            delay {
                statusCell.value.text = SSHRun(
                    command: self.tableData["data"][indexPath.row]["action"].stringValue,
                    cacheKey: self.tableData["data"][indexPath.row]["value"].stringValue,
                    isRefresh: self.isReload,
                    isRouter: self.isRouter
                )
            }

            return statusCell
        case "message":
            let statusCell = self.tableView.dequeueReusableCell(withIdentifier: "dataCell") as! tableDataCell
            statusCell.value.text = tableData["data"][indexPath.row]["action"].stringValue
            statusCell.label.text = tableData["data"][indexPath.row]["value"].stringValue
            return statusCell
        case "webview":
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "webCell") as! tableLinkCell
            if tableData["data"][indexPath.row]["text"].stringValue.isEmpty {
                cell.link.text = tableData["data"][indexPath.row]["value"].stringValue
            } else {
                cell.link.text = tableData["data"][indexPath.row]["text"].stringValue
            }
            return cell
        case "action":
            let actionCell = self.tableView.dequeueReusableCell(withIdentifier: "actionCell") as! tableActionCell
            actionCell.value.text = tableData["data"][indexPath.row]["value"].stringValue
            actionCell.label.text = tableData["data"][indexPath.row]["action"].stringValue
            return actionCell
        default:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "lableCell") as! tableLableCell
            cell.title.text = tableData["data"][indexPath.row]["value"].stringValue
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableData["data"][indexPath.row]["type"].stringValue {
        case "action":
            self.runCommand(indexPath: indexPath.row)
            break
        case "webview":
            let url = NSURL(string: tableData["data"][indexPath.row]["value"].stringValue)
            let svc = SFSafariViewController(url: url! as URL)
            present(svc, animated: true, completion: nil)
            break
        case "status":
            self.forceReload()
            break
        default:
            self.tableView.reloadData()
        }
    }

}
