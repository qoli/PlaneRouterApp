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
import SafariServices
import Localize_Swift
import MessageUI

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

class settingADDCell: UITableViewCell {

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

class settingRowCell: UITableViewCell {
    @IBOutlet weak var row: UILabel!
    @IBOutlet weak var imageRow: UIImageView!
    
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

class versionCell: UITableViewCell {
    
    @IBOutlet weak var version: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
}



class SettingTable_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    // MARK: - Setting Page

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

    // MARK: - Prepare Segue

    var isAdd: Bool = true
    var isRouter: Bool = false
    var config: connectClass.ConnectStruct!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goSettingDetailSegue" {
            if let destinationVC = segue.destination as? SettingDetail_ViewController {
                destinationVC.isAdd = self.isAdd
                destinationVC.isRouter = self.isRouter
                destinationVC.config = self.config
            }
        }
    }
    @IBAction func goAppView(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyBoard.instantiateViewController(withIdentifier: "AppView") as! App_ViewController
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: true, completion: nil)
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
        let uConfig = ConnectConfig.getAllJSON()
        print(uConfig)
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

    var userJSON: [JSON] = []
    var tableJSON: JSON!
    var tableArray: [Any] = []
    var tableData: JSON!

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
            if OSLanguage == "sc" {
                cell.title.text = self.tableData[indexPath.row]["titlesc"].stringValue
            }
            if OSLanguage == "tc" {
                cell.title.text = self.tableData[indexPath.row]["titletc"].stringValue
            }

            return cell
        case "row":
            let cell = tableView.dequeueReusableCell(withIdentifier: "row") as! settingRowCell
            cell.row.text = self.tableData[indexPath.row]["title"].stringValue
            if OSLanguage == "sc" {
                cell.row.text = self.tableData[indexPath.row]["titlesc"].stringValue
            }
            if OSLanguage == "tc" {
                cell.row.text = self.tableData[indexPath.row]["titletc"].stringValue
            }
            if self.tableData[indexPath.row]["icon"].stringValue != "" {
                cell.imageRow.image = UIImage(named: self.tableData[indexPath.row]["icon"].stringValue)
            }
            return cell
        case "add":
            let cell = tableView.dequeueReusableCell(withIdentifier: "add") as! settingADDCell
            return cell
        case "version":
            let cell = tableView.dequeueReusableCell(withIdentifier: "version") as! versionCell
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
            let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            cell.version.text = "Version \(appVersion ?? "1.0") Build \(buildNumber ?? "0") © 2019 R.ONE"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ssh") as! settingSSHCell
            cell.name.text = self.tableData[indexPath.row]["name"].stringValue
            return cell
        }

    }

    // MARK: did Select Row

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch self.tableData[indexPath.row]["type"].stringValue {
        case "title":
            break
        case "row":
            switch self.tableData[indexPath.row]["do"].stringValue {
                //
            case "refreshModel":
                let model = SSHRun(command: "nvram get model", cacheKey: "nvramGetModel", isRefresh: true)
                let alert = UIAlertController(title: model.removingWhitespacesAndNewlines, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))

                self.present(alert, animated: true)
            case "appPushID":
                let PushID = CacheString(Key: "DeviceToken")
                let alert = UIAlertController(title: PushID.removingWhitespacesAndNewlines, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: nil))

                self.present(alert, animated: true)
            case "reset":
                showMessageResetApp()
                //
            case "openweb":
                let url = NSURL(string: self.tableData[indexPath.row]["value"].stringValue)
                let svc = SFSafariViewController(url: url! as URL)
                present(svc, animated: true, completion: nil)
            case "sendMail":
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([self.tableData[indexPath.row]["value"].stringValue])
                    mail.setSubject("[Feedback]Plane Router App")

                    present(mail, animated: true)
                } else {
                    print("send mail 取消")
                }
            case "share":
                let url = NSURL(string: "itms-apps://itunes.apple.com/app/bars/id1452044466")
                if UIApplication.shared.canOpenURL(url! as URL) {
                    UIApplication.shared.open(url! as URL)
                }
            default:
                break
            }
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
            self.config = ConnectConfig.getByID(identifier: self.tableData[indexPath.row]["identifier"].stringValue)
            self.performSegue(withIdentifier: "goSettingDetailSegue", sender: nil)

        }
    }


    // MARK: -

    func showMessageResetApp() {
        let exitAppAlert = UIAlertController(title: "Restart App is needed".localized(),
                                             message: "We need to exit the app on Clear all Data.\nPlease reopen the app after this.".localized(),
                                             preferredStyle: .alert)

        let resetApp = UIAlertAction(title: "Close Now".localized(), style: .destructive) {
            (alert) -> Void in

            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()

            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                exit(EXIT_SUCCESS)
            })
        }

        let laterAction = UIAlertAction(title: "Later".localized(), style: .cancel) {
            (alert) -> Void in
            //
        }

        exitAppAlert.addAction(resetApp)
        exitAppAlert.addAction(laterAction)
        present(exitAppAlert, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
