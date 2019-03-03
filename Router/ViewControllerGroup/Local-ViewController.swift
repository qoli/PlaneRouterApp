//
//  Local-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/7.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero
import NMSSH
import PKHUD
import Alamofire
import SwiftyJSON

class tableTitleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

class commandListCell: UITableViewCell {
    @IBOutlet weak var commandTitleLabel: UILabel!
    @IBOutlet weak var commandLabel: UILabel!
    @IBOutlet weak var tableImageView: UIImageView!
}

class Local_ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var commandTitle = [
        "狀態",
        "國外連線",
        "WAN IP",
        "Date",
        "可用指令",
        "安裝插件到路由器"
    ]
    var commandList = [
        "",
        "sh /tmp/home/root/sstest.sh",
        "nvram get wan0_realip_ip",
        "date",
        "",
        "cd /tmp && wget https://raw.githubusercontent.com/hq450/fancyss/master/fancyss_arm/shadowsocks.tar.gz && tar -zxvf /tmp/shadowsocks.tar.gz && chmod +x /tmp/shadowsocks/install.sh && sh /tmp/shadowsocks/install.sh"
    ]
    var tableCellType = [
        "Title",
        "Status",
        "Status",
        "Status",
        "Title",
        "Command"
    ]

    var isR = false
    var passCommand = ""
//    var remoteData: JSON!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hero
        backButton.hero.modifiers = [.fade, .translate(x: 50)]
        commandTableView.hero.modifiers = [.fade, .translate(y: 50)]

        //
        getTableData()
    }

    func ifDataNeedUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let timestampNow = NSDate().timeIntervalSince1970
            let timestampCache = SSHRun(command: "date +%s", cacheKey: "timestamp", isRefresh: false)
            let IntTimestampNow: Int! = Int(timestampNow)
            let IntTimestampCache: Int! = (timestampCache as NSString).integerValue
            print("timestampNow: \(timestampNow)  timestampCache: \(timestampCache)")
            print("\(String(describing: IntTimestampNow)) - \(String(describing: IntTimestampCache)) = \(IntTimestampNow - IntTimestampCache)")
            if (IntTimestampNow - IntTimestampCache) >= 30 {
                self.ForceReload()
            }
        }
    }
    
    let cacheKey = "com.qoli.rJSON"
    func getTableData() {
        let cacheKey = "com.qoli.rJSON"
        let cacheObject = UserDefaults.standard.object(forKey: cacheKey)
        var rJSON: JSON!
        
        if cacheObject != nil {
            print("[onCache]")
            rJSON = JSON(cacheObject as Any)
            self.commandTitle = rJSON["commandTitle"].rawValue as! [String]
            self.commandList = rJSON["commandList"].rawValue as! [String]
            self.tableCellType = rJSON["tableCellType"].rawValue as! [String]
            
            self.tableview_init()
        } else {
            self.tableview_init()
            self.fetchRequest()
        }
        
//        ifDataNeedUpdate()
    }

    func fetchRequest() {

        var rJSON: JSON!
        
        // Fetch Request
        print("[Fetch Request]")
        HUD.flash(.label("載入中"), delay: 1.2) { _ in
            HUD.show(.progress)
        }
        
        Alamofire.request("https://raw.githubusercontent.com/qoli/AtomicR/master/scripts/router/command.json", method: .get)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("# Request success")
                    UserDefaults.standard.set(value, forKey: self.cacheKey)
                    rJSON = JSON(value)
                    self.commandTitle = rJSON["commandTitle"].rawValue as! [String]
                    self.commandList = rJSON["commandList"].rawValue as! [String]
                    self.tableCellType = rJSON["tableCellType"].rawValue as! [String]
                    
                    self.tableview_update()
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }


    }

    func ForceReload() {
        print("ForceReload")
        HUD.show(.progress)
        _ = SSHRun(command: "date +%s", cacheKey: "timestamp", isRefresh: true)
        self.isR = true
        self.tableview_update()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isR = false
        }
    }

    func goRouterSetting() {

        // 1
        let optionMenu = UIAlertController(title: nil, message: "操作選項", preferredStyle: .actionSheet)

        optionMenu.addAction(UIAlertAction(title: "路由器連線設定", style: .default, handler: { action in
            self.performSegue(withIdentifier: "goRouterSetting", sender: nil)
        }))
        optionMenu.addAction(UIAlertAction(title: "重新從網絡載入指令列表", style: .default, handler: { action in
            self.fetchRequest()
        }))
        optionMenu.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // 5
        self.present(optionMenu, animated: true, completion: nil)


    }

    @IBAction func tapSettingAction(_ sender: UIButton) {
        self.goRouterSetting()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTerminalViewandRun" {
            if let destinationVC = segue.destination as? Terminal_ViewController {
                destinationVC.passCommand = self.passCommand
            }
        }
    }

    func runCommand(indexPath: Int) {
        self.passCommand = commandList[indexPath] + " \n"
        self.performSegue(withIdentifier: "goTerminalViewandRun", sender: nil)
    }

    // Back & Nav
    @IBOutlet weak var backButton: UIButton!

    @IBAction func TapBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // command TableView
    @IBOutlet weak var commandTableView: UITableView!

    func tableview_init() {
        commandTableView.delegate = self
        commandTableView.dataSource = self
    }

    func tableview_update() {
        commandTableView.reloadData()
        commandTableView.refreshControl?.endRefreshing()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch tableCellType[indexPath.row] {
        case "Command":
            self.runCommand(indexPath: indexPath.row)
        case "Status":
            self.ForceReload()
        default:
            self.tableview_update()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return commandTitle.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch tableCellType[indexPath.row] {
        case "Title":
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "TableTitle") as! tableTitleCell
            titleCell.titleLabel.text = commandTitle[indexPath.row]
            return titleCell
        case "Status":
            let labelCell = tableView.dequeueReusableCell(withIdentifier: "LabelCell") as! commandListCell
            labelCell.commandTitleLabel.text = "..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                labelCell.commandTitleLabel.text = SSHRun(command: self.commandList[indexPath.row], cacheKey: "commandList_\(indexPath.row)", isRefresh: self.isR)
                if self.commandTitle[indexPath.row] == "Date" {
                    HUD.hide(afterDelay: 0.3)
                }
            }

            labelCell.commandLabel.text = commandTitle[indexPath.row]
            labelCell.tableImageView.image = UIImage(named: "iconStatus")
            return labelCell
        default:
            let labelCell = tableView.dequeueReusableCell(withIdentifier: "LabelCell") as! commandListCell
            labelCell.commandTitleLabel.text = commandTitle[indexPath.row]
            labelCell.commandLabel.text = commandList[indexPath.row]
            return labelCell
        }



    }

}
