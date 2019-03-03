//
//  List-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/23.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import Alamofire
import SwiftyJSON
import JGProgressHUD
import PlainPing
import PopMenu
import NotificationBannerSwift

class listTableCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
}

class List_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var category = ""
    var passCommand = ""

    var isPing = false
    var pings: [String] = []
    var delayData: [String: String] = [:]

    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // ui
//        self.hud = JGProgressHUD(style: .dark)

        // data
        delayData = UserDefaults.standard.dictionary(forKey: "ssPing") as? [String: String] ?? [:]

        // func
        table_init()
    }

    // seuge

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTerminalViewandRun" {
            if let destinationVC = segue.destination as? Terminal_ViewController {
                destinationVC.passCommand = self.passCommand
                destinationVC.category = self.category
            }
        }
    }

    //

    @IBAction func CloseAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func PingAction(_ sender: UIButton) {
        self.isPing = true
        ping()
    }

    //

    var pingsCount:Int?
    
    func ping() {
        for i in self.sourceData {
            pings.append(self.dataDict["ssconf_basic_server_\(i[1])"] ?? "")
        }

        self.hud = JGProgressHUD(style: .dark)
        hud.detailTextLabel.text = "Total: \(pings.count)"
        self.pingsCount = pings.count
        hud.textLabel.text = "Checking Latency"
        hud.show(in: self.view)

        pingNext()
    }

    func pingNext() {
        guard pings.count > 0 else {
            UIView.animate(withDuration: 0.1, animations: {
                self.hud.textLabel.text = nil
                self.hud.detailTextLabel.text = nil
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            })

            hud.dismiss(afterDelay: 1.0)

            UserDefaults.standard.set(self.delayData, forKey: "ssPing")
            self.tableView.reloadData()
            return
        }

        let ping = pings.removeFirst()
        PlainPing.ping(ping, withTimeout: 1.0, completionBlock: { (timeElapsed: Double?, error: Error?) in
            self.hud.detailTextLabel.text = "\(ping)\n\(self.pings.count) / \(self.pingsCount ?? 0)"
            
            if let latency = timeElapsed {
                print("\(ping) latency (ms): \(latency)")
                self.delayData[ping] = String(format: "%.2f", latency)
            }
            if let error = error {
                print("error: \(error.localizedDescription)")
                self.delayData[ping] = "0"
            }
            self.pingNext()
        })
    }

    //MARK: - Table
    
    var sourceData:[[String]] = []
    var dataDict: [String: String] = [:]

    func table_init() {
        self.tableView.addSubview(self.refreshControl)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        table_update()
    }

    func table_update(isRefresh: Bool = false) {
        
        refreshControl.beginRefreshing()
        
        delay {
            updateSSData(isRefresh: isRefresh, completionHandler: { value,error in
                self.refreshControl.endRefreshing()
                self.sourceData = []
                
                if value != [:] {
                    for v in value {
                        if v.key.hasPrefix("ssconf_basic_name_") {
                            let tmp = "\(v.key)=\(v.value)"
                            let ssconfBasicNames = tmp.groups(for: "ssconf_basic_name_(.*?)=(.*?)$")
                            self.sourceData.append(ssconfBasicNames[0])
                        }
                    }
                    self.dataDict = value
                    self.sourceData = self.sourceData.sorted(by: { ($0[1] as NSString).integerValue < ($1[1] as NSString).integerValue })
                    self.tableView.reloadData()
                } else {
                    let banner = NotificationBanner(title: "Net Error", subtitle: error?.localizedDescription, style: .warning)
                    banner.show()
                }
            })
        }
        
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
        self.table_update(isRefresh: true)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let action1 = UITableViewRowAction(style: .normal, title: "编辑") { action, index in
            print("more button tapped")
        }
        action1.backgroundColor = UIColor.mainBlue

        let action2 = UITableViewRowAction(style: .normal, title: "删除") { action, index in
            print("favorite button tapped")
        }
        action2.backgroundColor = UIColor.watermelon

        return [action2, action1]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! listTableCell
        if sourceData[indexPath.row].count != 1 {
            cell.label.text = sourceData[indexPath.row][2]

            if self.delayData.count != 0 || isPing {
                let domain: String = self.dataDict["ssconf_basic_server_\(sourceData[indexPath.row][1])"] ?? ""
                cell.delayLabel.text = "\((self.delayData[domain] ?? "0")) ms"
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let manager = PopMenuManager.default
        manager.actions = []
        manager.actions.append(PopMenuDefaultAction(
            title: "Connect",
            image: UIImage(named: "iconFontPaperPlane"),
            didSelect: { action in
                delay {
                    self.setLineinSSH(indexPath: indexPath)
                }
        }))
        manager.present(on: self)

    }

    var hud: JGProgressHUD!
    func setLineinSSH(indexPath: IndexPath) {
        delay(0) {
            self.hud = JGProgressHUD(style: .dark)
            self.hud.show(in: self.view)
        }

        delay(0.1) {
            let ssNumber = self.sourceData[indexPath.row][1]
            let method = self.dataDict["ssconf_basic_method_\(ssNumber)"] ?? ""
            let password = self.dataDict["ssconf_basic_password_\(ssNumber)"] ?? ""
            let port = self.dataDict["ssconf_basic_port_\(ssNumber)"] ?? ""
            let param = self.dataDict["ssconf_basic_rss_protocol_param_\(ssNumber)"] ?? ""
            let server = self.dataDict["ssconf_basic_server_\(ssNumber)"] ?? ""

            _ = SSHRun(command: "dbus set ss_basic_enable=1")
            _ = SSHRun(command: "dbus set ss_basic_method=\(method)")
            _ = SSHRun(command: "dbus set ss_basic_password=\(password)")
            _ = SSHRun(command: "dbus set ss_basic_port=\(port)")
            _ = SSHRun(command: "dbus set ss_basic_rss_protocol_param=\(param)")
            _ = SSHRun(command: "dbus set ss_basic_server=\(server)")
            _ = SSHRun(command: "dbus set ssconf_basic_node=\(ssNumber)")

            self.performSegue(withIdentifier: "goCommandReadSegue", sender: nil)
        }

        delay(0.2) {
            self.hud.dismiss(afterDelay: 1.0)
        }
    }




}
