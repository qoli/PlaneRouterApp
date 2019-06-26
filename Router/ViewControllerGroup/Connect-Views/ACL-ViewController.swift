//
//  ACL-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/24.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import Alamofire
import SwiftyJSON
import Chrysan
import PopMenu
import Localize_Swift

class aclTableCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ip: UILabel!

    @IBOutlet weak var mode: UILabel!
}

var cacheData: [String: String]?

class ACL_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!

    var isNeedApply = false

    override func viewDidLoad() {
        super.viewDidLoad()

        //
        cacheData = UserDefaults.standard.dictionary(forKey: "ssData") as? [String: String]

        //
        table_init()
    }

    //
    @IBAction func closeAtion(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func applyAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goCommandReadSegue", sender: nil)
        self.isNeedApply = false
    }

    // table

    var sourceData: [[String]] = []
    var dataDict: [String: String] = [:]
    var lastNumber: Int = 0
    let ACL: [Int: String] = [
        0: "No Proxy",
        1: "GFW Mode",
        2: "White List",
        3: "Game Mode",
        4: "Global",
        5: "Back to China",
    ]

    func table_init() {
        self.tableView.addSubview(self.refreshControl)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        table_update()
    }

    func table_update(isRefresh: Bool = false) {
        refreshControl.beginRefreshing()

        delay {
            updateSSData(isRefresh: isRefresh, completionHandler: { value, error in
                self.refreshControl.endRefreshing()
                self.sourceData = []

                if value != [:] {
                    for v in value {
                        if v.key.hasPrefix("ss_acl_ip_") {
                            let tmp = "\(v.key)=\(v.value)"
                            let ssconfBasicNames = tmp.groups(for: "ss_acl_ip_(.*?)=(.*?)$")
                            self.sourceData.append(ssconfBasicNames[0])
                        }
                    }

                    self.dataDict = value
                    self.sourceData = self.sourceData.sorted(by: { ($0[1] as NSString).integerValue < ($1[1] as NSString).integerValue })
                    self.tableView.reloadData()

                    if self.isNeedApply {
                        self.applyButton.isEnabled = true
                    } else {
                        self.applyButton.isEnabled = false
                    }

                } else {
                    self.chrysan.show(.error, message: error?.localizedDescription ?? "error", hideDelay: 1)
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
        return sourceData.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != sourceData.count {
            //
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! aclTableCell
            let name = self.dataDict["ss_acl_name_\(sourceData[indexPath.row][1])"] ?? ""
            let ip = sourceData[indexPath.row][2]
            let mode = self.dataDict["ss_acl_mode_\(sourceData[indexPath.row][1])"] ?? "0"

            cell.name.text = name
            cell.ip.text = ip
            cell.mode.text = getMode(mode: mode).0

            self.lastNumber = (sourceData[indexPath.row][1] as NSString).integerValue
            return cell
        } else {
            //
            let cell: UITableViewCell! = self.tableView.dequeueReusableCell(withIdentifier: "add")
            return cell
        }

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tap: \(indexPath.row) \(sourceData.count)")

        if indexPath.row == sourceData.count {
            devices()
        }

        if indexPath.row < sourceData.count {
            tableView_selected(indexPath: indexPath)
        }

    }

    // MARK: click ADD

    func devices() {

        delay(0) {
            self.chrysan.show()
        }

        delay {
            let devices = SSHRun(command: "cat /var/lib/misc/dnsmasq.leases | awk '{print $3,$4}'", isRefresh: true)
            let ds = devices.groups(for: "(.*) (.*)")

            let manager = PopMenuManager.default
            manager.actions = []

            for d in ds {
                if d.count == 3 {
                    let ip = d[1]
                    var name = d[2]
                    if name == "*" {
                        name = ip
                    }
                    manager.actions.append(PopMenuDefaultAction(
                        title: name,
                        didSelect: { action in
                            delay {
                                print("ip: \(d[2]), name: \(d[1])")
                                self.ACL_Add(number: "\(self.lastNumber + 1)", ip: ip, name: name)
                            }
                        }))

                }
            }

            manager.popMenuAppearance.popMenuActionCountForScrollable = 10
            manager.present(on: self)
        }

        delay(0.3) {
            self.chrysan.show(hideDelay: 0.4)
        }

    }

    func ACL_Add(number: String, ip: String, name: String) {
        let manager = PopMenuManager.default
        let ACLSorted = ACL.sorted(by: { $0.0 < $1.0 })
        manager.actions = []
        for a in ACLSorted {
            manager.actions.append(PopMenuDefaultAction(
                title: a.value,
                didSelect: { action in
                    self.ACLSetting(number: number, mode: "\(a.key)", ip: ip, name: name)
                }))

        }
        manager.popMenuAppearance.popMenuActionCountForScrollable = 10
        manager.present(on: self)
    }

    func tableView_selected(indexPath: IndexPath) {

        let controller = PopMenuViewController(actions: [
            PopMenuDefaultAction(
                title: "No Proxy".localized(),
                didSelect: { action in
                    self.ACLSetting(number: self.sourceData[indexPath.row][1], mode: "0")
                }
            ),
            PopMenuDefaultAction(
                title: "GFW Mode".localized(),
                didSelect: { action in
                    self.ACLSetting(number: self.sourceData[indexPath.row][1], mode: "1")
                }
            ),
            PopMenuDefaultAction(
                title: "White List".localized(),
                didSelect: { action in
                    self.ACLSetting(number: self.sourceData[indexPath.row][1], mode: "2")
                }
            ),
            PopMenuDefaultAction(
                title: "Game Mode".localized(),
                didSelect: { action in
                    self.ACLSetting(number: self.sourceData[indexPath.row][1], mode: "3")
                }
            ),
            PopMenuDefaultAction(
                title: "Global".localized(),
                didSelect: { action in
                    self.ACLSetting(number: self.sourceData[indexPath.row][1], mode: "4")
                }
            ),
            PopMenuDefaultAction(
                title: "Back to China".localized(),
                didSelect: { action in
                    self.ACLSetting(number: self.sourceData[indexPath.row][1], mode: "5")
                }
            ),
            PopMenuDefaultAction(
                title: "Remove".localized(),
                didSelect: { action in
                    self.ACLSetting(number: self.sourceData[indexPath.row][1], mode: "6")
                }
            ),

        ])

        controller.appearance.popMenuActionCountForScrollable = 10
        present(controller, animated: true, completion: nil)
    }

    func getMode(mode: String) -> (String, String) {
        switch mode {
        case "6":
            return ("Remove", "")
        case "5":
            return ("BacktoChina", "22,80,443")
        case "4":
            return ("Global", "22,80,443")
        case "3":
            return ("Game Mode", "all")
        case "2":
            return ("White List", "22,80,443")
        case "1":
            return ("GFW Mode", "80,443")
        default:
            return ("No Proxy", "all")
        }
    }

    // MARK: - ACL Setting

    func ACLSetting(number: String, mode: String, ip: String = "", name: String = "") {
        print("ACLSetting: number '\(number)' ,mode '\(mode)' ,ip '\(ip)' ,name '\(name)'")

        delay(0) {
            self.chrysan.show()
        }

        delay {
            switch routerModel.runningModel {
            case .arm:

                var urlParams = ["": ""]

                if mode == "6" {
                    urlParams = [
                        "use_rm": "1",
                        "p": "ss_acl",
                        "ss_acl_ip_\(number)": "",
                        "ss_acl_name_\(number)": "",
                        "ss_acl_port_\(number)": "",
                        "ss_acl_mode_\(number)": "",
                    ]
                } else {
                    if ip == "" {
                        urlParams = [
                            "p": "ss_acl",
                            "ss_acl_ip_\(number)": self.dataDict["ss_acl_ip_\((number as NSString).integerValue)"] ?? "",
                            "ss_acl_name_\(number)": self.dataDict["ss_acl_name_\((number as NSString).integerValue)"] ?? "",
                            "ss_acl_port_\(number)": self.getMode(mode: mode).1,
                            "ss_acl_mode_\(number)": mode,
                        ]
                    } else {
                        urlParams = [
                            "p": "ss_acl",
                            "ss_acl_ip_\(number)": ip,
                            "ss_acl_name_\(number)": name,
                            "ss_acl_port_\(number)": self.getMode(mode: mode).1,
                            "ss_acl_mode_\(number)": mode,
                        ]
                    }
                }

                print(urlParams)

                // Fetch Request
                Alamofire.request("\(buildUserURL())/applydb.cgi", method: .get, parameters: urlParams)
                    .validate(statusCode: 200..<300)
                    .responseString(encoding: String.Encoding.utf8) { response in
                        switch response.result {
                        case .success(_):
                            self.isNeedApply = true
                            self.table_update(isRefresh: true)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                }

            case .hnd:

                var body: [String: Any]?

                if mode == "6" {
                    // remove
                    body = [
                        "fields": [
                            "ss_acl_ip_\(number)": "",
                            "ss_acl_name_\(number)": "",
                            "ss_acl_port_\(number)": "",
                            "ss_acl_mode_\(number)": "",
                        ],
                        "id": 65940754,
                        "method": "dummy_script.sh",
                        "params": [

                        ]
                    ]
                } else {
                    if ip == "" {
                        // JSON Body
                        body = [
                            "fields": [
                                "ss_acl_ip_\(number)": "\(self.dataDict["ss_acl_ip_\((number as NSString).integerValue)"] ?? "")",
                                "ss_acl_name_\(number)": "\(self.dataDict["ss_acl_name_\((number as NSString).integerValue)"] ?? "")",
                                "ss_acl_port_\(number)": "\(self.getMode(mode: mode).1)",
                                "ss_acl_mode_\(number)": "\(mode)"
                            ],
                            "id": 65940754,
                            "method": "dummy_script.sh",
                            "params": [

                            ]
                        ]
                    } else {
                        // JSON Body
                        body = [
                            "fields": [
                                "ss_acl_ip_\(number)": "\(ip)",
                                "ss_acl_name_\(number)": "\(name)",
                                "ss_acl_port_\(number)": "\(self.getMode(mode: mode).1)",
                                "ss_acl_mode_\(number)": "\(mode)"
                            ],
                            "id": 65940754,
                            "method": "dummy_script.sh",
                            "params": [

                            ]
                        ]
                    }
                }

                // Fetch Request
                Alamofire.request("\(buildUserURL())/_api/", method: .post, parameters: body, encoding: JSONEncoding.default)
                    .validate(statusCode: 200..<300)
                    .responseJSON { response in
                        switch response.result {
                        case .success(_):
                            self.isNeedApply = true
                            self.table_update(isRefresh: true)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                }


            } // switch
        } // delay
        
        
        delay(0.3) {
            self.chrysan.show(hideDelay: 0.4)
        }
    } // func



}
