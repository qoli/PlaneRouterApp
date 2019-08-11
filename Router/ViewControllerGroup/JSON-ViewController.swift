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
import PopMenu
import SafariServices
import Localize_Swift

class tableLableCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
}

class tableDataCell: UITableViewCell {
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var label: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none

        if selected {
            UIView.animate(withDuration: 0.1, animations: {
                self.layer.opacity = 0.3
            }, completion: { _ in
                UIView.animate(withDuration: 0.6, animations: {
                    self.layer.opacity = 1
                })
            })
        }
    }
}

class tableActionCell: UITableViewCell {
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var label: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none

        if selected {
            UIView.animate(withDuration: 0.1, animations: {
                self.layer.opacity = 0.3
            }, completion: { _ in
                UIView.animate(withDuration: 0.6, animations: {
                    self.layer.opacity = 1
                })
            })
        }
    }
}

class tableLinkCell: UITableViewCell {
    @IBOutlet weak var link: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none

        if selected {
            UIView.animate(withDuration: 0.1, animations: {
                self.layer.opacity = 0.3
            }, completion: { _ in
                UIView.animate(withDuration: 0.6, animations: {
                    self.layer.opacity = 1
                })
            })
        }
    }
}

// MARK: - JSON_ViewController

class JSON_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var pageDesc: UILabel!
    @IBOutlet weak var pageButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - view

    override func viewDidLoad() {
        super.viewDidLoad()

        //添加通知
        addNotification()

        //
        table_init()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        page_init()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notification

    func addNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(JSONCall(_:)),
            name: NSNotification.Name(rawValue: "JSONCall"),
            object: nil
        )
    }

    @objc func JSONCall(_ notification: Notification) {
//        self.jsonName = notification.object
        let no = notification.object as! serviceListClass.serviceStruct
        self.jsonName = no.name
        self.Service = no
        page_init()
    }

    // MARK: - Page init
    var Service: serviceListClass.serviceStruct!
    var jsonName = "Shadowsock"

    func page_init() {
        pageGetSrouce()

        if jsonName == "Shadowsock" {
            switch routerModel.runningModel {
            case .arm:
                pageDesc.text = "Router: ARM Model · \(routerModel.modelName)"
            case .hnd:
                pageDesc.text = "Router: HND Model  · \(routerModel.modelName)"
            }

            pageButton.isHidden = true
        } else {
            updateService()
            pageButton.isHidden = false
        }
    }

    func updateService() {
        Service = ServiceList.getSerivce(identifier: Service.identifier)
        
        var name = Service.connectID
        if name == "" {
            name = "No Setup.".localized()
        } else {
            name = ConnectConfig.getByID(identifier: Service.connectID).name
        }
        pageDesc.text = "SSH: \(name)"
    }

    // MARK: - Page Action

    @IBAction func pageAction(_ sender: UIButton) {
        // 1. Hidden install category & items
        // 2. switch SSH Config
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let manager = PopMenuManager.default
        manager.actions = []
        manager.actions.append(PopMenuDefaultAction(
            title: "Setup SSH".localized(),
            image: UIImage(named: "iconFontPlug"),
            didSelect: { action in
                delay {

                    let managerSSH = PopMenuManager.default
                    managerSSH.actions = []
                    for config in ConnectConfig.getAll() {
                        managerSSH.actions.append(PopMenuDefaultAction(
                            title: config.name,
                            didSelect: { action in
                                delay {
                                    print("Select: \(config)")
                                    ServiceList.updateSerivceConnectID(identifier: self.Service.identifier, connectID: config.identifier)
                                    self.updateService()
                                }
                            }))
                    }

                    managerSSH.actions.append(PopMenuDefaultAction(
                        title: "Add Hosts".localized(),
                        didSelect: { action in
                            delay {
                                // self.performSegue(withIdentifier: "goSettingTableSegue", sender: nil)
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let nextView = storyBoard.instantiateViewController(withIdentifier: "SettingTableView") as! SettingTable_ViewController
                                nextView.modalPresentationStyle = .fullScreen
                                self.present(nextView, animated: true, completion: nil)
                            }
                        }))
                    managerSSH.present(on: self)

                }
            }))
        manager.actions.append(PopMenuDefaultAction(
            title: "Remove Screen".localized(),
            image: UIImage(named: "iconFontEraser"),
            didSelect: { action in
                delay {
                    ServiceList.removeSerice(identifier: self.Service.identifier)
                    NotificationCenter.default.post(name: NSNotification.Name.init("startCollection"), object: nil)
                }
            }))
        manager.present(sourceView: self.pageButton)

    }

    // MARK: - Load Page
    var isReload = false

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
        self.passCommand = tableData["data"][indexPath]["action"].stringValue + " \n"
        self.performSegue(withIdentifier: "goTerminalViewandRun", sender: nil)
    }

    // MARK: - Segue pass data

    var category = ""
    var passCommand = ""

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTerminalViewandRun" {
            if let destinationVC = segue.destination as? Terminal_ViewController {
                destinationVC.passCommand = self.passCommand
                destinationVC.category = self.category
                destinationVC.Service = self.Service
            }
        }
    }

    // MARK: - Table

    var isRouter = true
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

    // MARK: tap row

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
