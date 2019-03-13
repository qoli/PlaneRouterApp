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
import Localize_Swift

class listTableCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var desc: UILabel!
}

class List_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var goBottom: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // data
        delayData = UserDefaults.standard.dictionary(forKey: "ssPing") as? [String: String] ?? [:]

        // func
        table_init()
        
        delay(0.5) {
            if self.goBottom {
                let indexPath = IndexPath(row: self.sourceData.count-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    // MARK: - prepare seuge

    var category = ""
    var passCommand = ""
    var editNumber: Int = 0
    var isSSR: Bool = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTerminalViewandRun" {
            if let destinationVC = segue.destination as? Terminal_ViewController {
                destinationVC.passCommand = self.passCommand
                destinationVC.category = self.category
            }
        }
        if segue.identifier == "goAddNodeSegue" {
            if let destinationVC = segue.destination as? AddNode_ViewController {
                destinationVC.isEditMode = true
                destinationVC.editNumber = editNumber
                destinationVC.isSSR = self.isSSR
            }
        }
    }

    // MARK: - Close

    @IBAction func CloseAction(_ sender: UIButton) {
        var rootVC = self.presentingViewController
        while let parent = rootVC?.presentingViewController {
            rootVC = parent
        }
        //释放所有下级视图
        NotificationCenter.default.post(name: NSNotification.Name.init("collectionSelect"), object: 1)
        NotificationCenter.default.post(name: NSNotification.Name.init("ConnectViewonShow"), object: true)
        rootVC?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table

    var sourceData: [[String]] = []
    var dataDict: [String: String] = [:]

    func table_init() {
        self.tableView.addSubview(self.refreshControl)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        if !goBottom {
            table_update()
        } else {
            table_update(isRefresh: true)
        }
    }

    func table_update(isRefresh: Bool = false) {

        refreshControl.beginRefreshing()

        delay {
            updateSSData(isRefresh: isRefresh, completionHandler: { value, error in
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! listTableCell
        if sourceData[indexPath.row].count != 1 {
            cell.label.text = sourceData[indexPath.row][2]
            var type = "ss"
            if dataDict["ssconf_basic_type_\(self.sourceData[indexPath.row][1])"] == "0" {
                type = "ss"
            }
            if dataDict["ssconf_basic_type_\(self.sourceData[indexPath.row][1])"] == "1" {
                type = "ssr"
            }
            if dataDict["ssconf_basic_type_\(self.sourceData[indexPath.row][1])"] == "2" {
                type = "koolgame"
            }
            if dataDict["ssconf_basic_type_\(self.sourceData[indexPath.row][1])"] == "3" {
                type = "v2ray"
            }
            cell.desc.text = "\(type) · \(dataDict["ssconf_basic_server_\(self.sourceData[indexPath.row][1])"] ?? "")"

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
            title: "Connect".localized(),
            image: UIImage(named: "iconFontPaperPlane"),
            didSelect: { action in
                delay {
                    self.connectNode(indexPath: indexPath)
                }
            }))
        manager.present(on: self)

    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit".localized()) { action, index in
            self.editNumber = (self.sourceData[indexPath.row][1] as NSString).integerValue
            if self.dataDict["ssconf_basic_type_\(self.sourceData[indexPath.row][1])"] == "0" {
                self.isSSR = false
            }
            if self.dataDict["ssconf_basic_type_\(self.sourceData[indexPath.row][1])"] == "1" {
                self.isSSR = true
            }
            self.performSegue(withIdentifier: "goAddNodeSegue", sender: nil)
        }
        editAction.backgroundColor = UIColor.mainBlue
        
        let removeAction = UITableViewRowAction(style: .normal, title: "Remove".localized()) { action, index in
            //print("删除", self.sourceData[indexPath.row][2], self.sourceData[indexPath.row][1])
            let alertController = UIAlertController(title: "\(self.sourceData[indexPath.row][2]) \(self.sourceData[indexPath.row][1])", message: nil, preferredStyle: .actionSheet)
            
            alertController.addAction(
                UIAlertAction(
                    title: "Remove".localized(),
                    style: .destructive,
                    handler: { (action) -> Void in
                        self.removeNode(number: (self.sourceData[indexPath.row][1] as NSString).integerValue)
                }))
            
            alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
            self.present(alertController, animated: true, completion: nil)
        }
        removeAction.backgroundColor = UIColor.watermelon
        
        return [removeAction, editAction]
    }
    
    // MARK: - connect Node

    var hud: JGProgressHUD!
    func connectNode(indexPath: IndexPath) {
        delay(0) {
            self.hud = JGProgressHUD(style: .dark)
            self.hud.show(in: self.view)
        }

        delay(0.1) {
            let ssNumber = self.sourceData[indexPath.row][1]

            switch ModelPage.runningModel {
            case .arm:
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


            case .hnd:
                _ = SSHRun(command: "dbus set ss_basic_enable=1")
                _ = SSHRun(command: "dbus set ssconf_basic_node=\(ssNumber)")
            }

            self.performSegue(withIdentifier: "goCommandReadSegue", sender: nil)

        }

        delay(0.2) {
            self.hud.dismiss(afterDelay: 1.0)
        }
    }

    // MARK: - remove Node
    
    func removeNode(number: Int) {
        switch ModelPage.runningModel {
        case .arm:
            let urlParams = [
                "use_rm": "1",
                "p": "ssconf_basic",
                "ssconf_basic_name_\(number)": "",
                "ssconf_basic_server_\(number)": "",
                "ssconf_basic_server_ip_\(number)": "",
                "ssconf_basic_mode_\(number)": "",
                "ssconf_basic_port_\(number)": "",
                "ssconf_basic_password_\(number)": "",
                "ssconf_basic_method_\(number)": "",
                "ssconf_basic_rss_protocol_\(number)": "",
                "ssconf_basic_rss_protocol_param_\(number)": "",
                "ssconf_basic_rss_obfs_\(number)": "",
                "ssconf_basic_rss_obfs_param_\(number)": "",
                "ssconf_basic_use_kcp_\(number)": "",
                "ssconf_basic_ss_obfs_\(number)": "",
                "ssconf_basic_ss_obfs_host_\(number)": "",
                "ssconf_basic_koolgame_udp_\(number)": "",
                "ssconf_basic_ping_\(number)": "",
                "ssconf_basic_web_test_\(number)": "",
                "ssconf_basic_use_lb_\(number)": "",
                "ssconf_basic_lbmode_\(number)": "",
                "ssconf_basic_weight_\(number)": "",
                "ssconf_basic_group_\(number)": "",
                "ssconf_basic_v2ray_uuid_\(number)": "",
                "ssconf_basic_v2ray_alterid_\(number)": "",
                "ssconf_basic_v2ray_security_\(number)": "",
                "ssconf_basic_v2ray_network_\(number)": "",
                "ssconf_basic_v2ray_headtype_tcp_\(number)": "",
                "ssconf_basic_v2ray_headtype_kcp_\(number)": "",
                "ssconf_basic_v2ray_network_path_\(number)": "",
                "ssconf_basic_v2ray_network_host_\(number)": "",
                "ssconf_basic_v2ray_network_security_\(number)": "",
                "ssconf_basic_v2ray_mux_concurrency_\(number)": "",
                "ssconf_basic_v2ray_json_\(number)": "",
                "ssconf_basic_v2ray_use_json_\(number)": "",
                "ssconf_basic_v2ray_mux_enable_\(number)": "",
                "ssconf_basic_type_\(number)": ""
            ]
            
            // Fetch Request
            Alamofire.request("\(buildUserURL())/applydb.cgi", method: .get, parameters: urlParams)
                .validate(statusCode: 200..<300)
                .responseString(encoding: String.Encoding.utf8) { response in
                    if (response.result.error == nil) {
                        self.table_update(isRefresh: true)
                    }
                    else {
                        messageNotification(message: response.result.error?.localizedDescription ?? "error")
                    }
            }
        case .hnd:
            
            // JSON Body
            let body: [String : Any] = [
                "fields": [
                    "ssconf_basic_name_\(number)": "",
                    "ssconf_basic_server_\(number)": "",
                    "ssconf_basic_server_ip_\(number)": "",
                    "ssconf_basic_mode_\(number)": "",
                    "ssconf_basic_port_\(number)": "",
                    "ssconf_basic_password_\(number)": "",
                    "ssconf_basic_method_\(number)": "",
                    "ssconf_basic_rss_protocol_\(number)": "",
                    "ssconf_basic_rss_protocol_param_\(number)": "",
                    "ssconf_basic_rss_obfs_\(number)": "",
                    "ssconf_basic_rss_obfs_param_\(number)": "",
                    "ssconf_basic_use_kcp_\(number)": "",
                    "ssconf_basic_ss_obfs_\(number)": "",
                    "ssconf_basic_ss_obfs_host_\(number)": "",
                    "ssconf_basic_koolgame_udp_\(number)": "",
                    "ssconf_basic_ping_\(number)": "",
                    "ssconf_basic_web_test_\(number)": "",
                    "ssconf_basic_use_lb_\(number)": "",
                    "ssconf_basic_lbmode_\(number)": "",
                    "ssconf_basic_weight_\(number)": "",
                    "ssconf_basic_group_\(number)": "",
                    "ssconf_basic_v2ray_uuid_\(number)": "",
                    "ssconf_basic_v2ray_alterid_\(number)": "",
                    "ssconf_basic_v2ray_security_\(number)": "",
                    "ssconf_basic_v2ray_network_\(number)": "",
                    "ssconf_basic_v2ray_headtype_tcp_\(number)": "",
                    "ssconf_basic_v2ray_headtype_kcp_\(number)": "",
                    "ssconf_basic_v2ray_network_path_\(number)": "",
                    "ssconf_basic_v2ray_network_host_\(number)": "",
                    "ssconf_basic_v2ray_network_security_\(number)": "",
                    "ssconf_basic_v2ray_mux_concurrency_\(number)": "",
                    "ssconf_basic_v2ray_json_\(number)": "",
                    "ssconf_basic_v2ray_use_json_\(number)": "",
                    "ssconf_basic_v2ray_mux_enable_\(number)": "",
                    "ssconf_basic_type_\(number)": ""
                ],
                "id": 89105112,
                "method": "dummy_script.sh",
                "params": []
            ]
            
            // Fetch Request
            Alamofire.request("\(buildUserURL())/_api/", method: .post, parameters: body, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    if (response.result.error == nil) {
                        self.table_update(isRefresh: true)
                    }
                    else {
                        messageNotification(message: response.result.error?.localizedDescription ?? "error")
                    }
            }
        }// end switch
    }

    
    // MARK: - Ping
    
    var isPing = false
    var pings: [String] = []
    var delayData: [String: String] = [:]
    var pingsCount: Int?
    @IBOutlet weak var pingButton: UIButton!
    
    @IBAction func PingAction(_ sender: UIButton) {
        buttonTapAnimate(button: pingButton)
        self.isPing = true
        ping()
    }
    
    func ping() {
        for i in self.sourceData {
            pings.append(self.dataDict["ssconf_basic_server_\(i[1])"] ?? "")
        }
        
        self.hud = JGProgressHUD(style: .dark)
        hud.detailTextLabel.text = "Total: \(pings.count)".localized()
        self.pingsCount = pings.count
        hud.textLabel.text = "Checking Latency".localized()
        hud.show(in: self.view)
        
        pingNext()
    }
    
    func pingNext() {
        guard pings.count > 0 else {
            // ping 的數量小於或等於 0
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
        // ping 的數量大於 0
        
        let ping = pings.removeFirst()
        PlainPing.ping(ping, completionBlock: { (timeElapsed: Double?, error: Error?) in
            self.hud.detailTextLabel.text = "\(ping)\n\(self.pings.count) / \(self.pingsCount ?? 0)"
            
            // 正常
            if let latency = timeElapsed {
                print("\(ping) latency (ms): \(latency)")
                self.delayData[ping] = String(format: "%.2f", latency)
            }
            
            if let error = error {
                // 遇到錯誤
                print("error: \(error.localizedDescription)")
                self.delayData[ping] = "0"
            }
            
            self.pingNext()
            
        })
    }
    
}
