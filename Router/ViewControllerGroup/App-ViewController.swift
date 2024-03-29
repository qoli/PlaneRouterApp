//
//  App-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/18.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Chrysan
import Hero

class ServiceiconCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var shadowImage: UIImageView!
}

class App_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - IBOutlet

    @IBOutlet weak var PanSwipe: UIPanGestureRecognizer!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var childViewTop: NSLayoutConstraint!
    @IBOutlet weak var childViews: UIView!

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!


    @IBOutlet weak var serviceListView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var childNetView: UIView!
    @IBOutlet weak var childSSView: UIView!
    @IBOutlet weak var childJSONView: UIView!
    @IBOutlet weak var childAddView: UIView!

    // MARK: - var

    var selectServiceNumber: Int = 0
    var lastCollectionID = ""

    // MARK: - view

    override func viewDidLoad() {
        print("App View: viewDidLoad")
        super.viewDidLoad()
        self.appTitle.alpha = 0
        
        // Chrysan
        ChrysanConfig.default().hudStyle = .dark
        ChrysanConfig.default().color = .white
        ChrysanConfig.default().chrysanStyle = .whiteIndicator

        if UserDefaults.standard.bool(forKey: "isApp") == false {
            // goWalkSegue
            print("goWalkSegue")
            
            delay(0) {
                self.performSegue(withIdentifier: "goWalkSegue", sender: nil)
            }
        } else {
            self.showUpdateNotes(isForce: false)
            
            // Notification
            addNotification()
        }
        
        collection_init()
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("App View: viewWillDisappear")
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notification

    func addNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCollection(_:)),
            name: NSNotification.Name(rawValue: "updateCollection"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(startCollection(_:)),
            name: NSNotification.Name(rawValue: "startCollection"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(serviceListActionNotification(_:)),
            name: NSNotification.Name(rawValue: "appServiceList"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(collectionSelectNotification(_:)),
            name: NSNotification.Name(rawValue: "collectionSelect"),
            object: nil
        )
    }
    
    @objc func updateCollection(_ notification: Notification) {
        self.collection_update()
        self.collection_select(selected: self.items.count - 1)
    }
    
    @objc func startCollection(_ notification: Notification) {
        self.collection_update()
        self.collection_select(selected: 0)
    }

    @objc func serviceListActionNotification(_ notification: Notification) {
        servicePanelOnOff((notification.object != nil))
    }

    @objc func collectionSelectNotification(_ notification: Notification) {
        self.collection_select(selected: notification.object as! Int)
    }

    // MARK: - SettingAction

    @IBAction func SettingAction(_ sender: UIButton) {
        //self.performSegue(withIdentifier: "goSettingTableSegue", sender: nil)
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyBoard.instantiateViewController(withIdentifier: "SettingTableView") as! SettingTable_ViewController
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: true, completion: nil)
        
    }

    // MARK: - Update Notes

    func showUpdateNotes(isForce: Bool = false) {

        if isForce {
            delay(2) {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = storyBoard.instantiateViewController(withIdentifier: "UpdateNotesView") as! UpdateNotes_ViewController
                nextView.modalPresentationStyle = .overCurrentContext
                self.present(nextView, animated: true, completion: nil)
            }
            return
        }

        setCacheBool(value: false, Key: "isUpdate")
        let updateTimeCacheKey = "updateTime"
        let updateTime = CacheString(Key: updateTimeCacheKey)

        fetchRequestString(
            api: "https://raw.githubusercontent.com/qoli/AtomicR/master/Update/updatetime.txt",
            isRefresh: true,
            completionHandler: { value, error in
                let valueDate = value?.removingWhitespacesAndNewlines ?? ""
                var isUpdate = false
                if value != nil {
                    if updateTime != valueDate {
                        isUpdate = true
                        setCacheBool(value: true, Key: "isUpdate")
                        _ = CacheString(text: valueDate, Key: updateTimeCacheKey)
                        delay(2) {
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let nextView = storyBoard.instantiateViewController(withIdentifier: "UpdateNotesView") as! UpdateNotes_ViewController
                            nextView.modalPresentationStyle = .overCurrentContext
                            self.present(nextView, animated: true, completion: nil)
                        }
                    }
                }
                print("Update Time Remote: \(valueDate) · Loacl: \(updateTime) · isUpdate: \(isUpdate)")
            })
    }

    // MARK: - Service Panel ON or OFF

    @IBAction func PanSwipeAction(_ sender: UIPanGestureRecognizer) {
        if self.PanSwipe.state == .changed {
            let offY = self.PanSwipe.velocity(in: childViews).y
            if offY <= -150 {
                servicePanelOnOff(true)
            }
            if offY >= 150 {
                servicePanelOnOff(false)
            }
        }
    }

    @IBAction func serviceListMenuAction(_ sender: UIButton) {
        servicePanelOnOff(App.appListON)
    }

    func servicePanelOnOff(_ isON: Bool) {
        App.appListON = isON
        // 200 / 60
        if App.appListON {
            // 列表收起，面板展開
            self.childViewTop.constant = -158
            App.appListON = false
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.appTitle.alpha = 1
                self.menuButton.setBackgroundImage(UIImage(named: "iconMenuNormal"), for: .normal)
            })
        } else {
            // 列表展開，面板收起
            self.childViewTop.constant = 0
            App.appListON = true
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                self.appTitle.alpha = 0
                self.menuButton.setBackgroundImage(UIImage(named: "iconMenuActive"), for: .normal)
            })
        }

        NotificationCenter.default.post(name: NSNotification.Name.init("ConnectViewonList"), object: App.appListON)
    }

    // MARK: - collectionView

    // collectionView
    var previousSelected: IndexPath?
    var currentSelected: Int?

    var items: [serviceListClass.serviceStruct] = []
    let itemsImage = ["iconCustomSpeed", "iconCustomInternetNetwork", "iconCustomShadowsockLogo"]
//    let itemsFixed = ["Net Speed", "Connect", "Shadowsock"]
    var itemsFixed: [serviceListClass.serviceStruct] = []

    func collection_select(selected: Int = 0) {
        print("collection_select: \(selected)")
        let indexPath = IndexPath(row: selected, section: 0)
        self.collectionView(self.collectionView, didSelectItemAt: indexPath)
    }

    func collection_init() {

        collectionView.dataSource = self
        collectionView.delegate = self

        fixedItem()

        collection_update()
        delay(0.1) {
            self.collection_select()
        }
    }

    func fixedItem() {
        let r = ServiceList.buildFixed(name: "Net Speed")
        let c = ServiceList.buildFixed(name: "Connect")
        let s = ServiceList.buildFixed(name: "Shadowsock")
        self.itemsFixed.append(r)
        self.itemsFixed.append(c)
        self.itemsFixed.append(s)

    }

    // MARK: - item Update

    func collection_update() {
        self.items = self.itemsFixed
        let list = ServiceList.getSerivces()
        for i in list {
            items.append(i)
        }
        items.append(ServiceList.buildFixed(name: "Add"))
        self.collectionView.reloadData()
    }

    func collectionCell_selected(isSelected: Bool, cell: ServiceiconCollectionViewCell?, indexPath: IndexPath) {
        if cell != nil {
            if isSelected {
                self.selectServiceNumber = indexPath.row
                self.appTitle.text = self.items[self.selectServiceNumber].name

                cell?.shadowImage.image = UIImage(named: "serviceShadowActive")
                cell?.shadowImage.frame.origin.y = 6

                // imageView.image
                if self.items[indexPath.item].name == "Add" {
                    cell?.imageView.image = UIImage(named: "iconCustomAddW")
                } else {
                    if indexPath.item < self.itemsFixed.count {
                        cell?.imageView.image = UIImage(named: "\(self.itemsImage[indexPath.item])W")
                    } else {
                        cell?.imageView.image = UIImage(named: "iconCustomTerminalW")
                    }
                }


                delay(0) {
                    cell?.cellView.backgroundColor = UIColor(named: "mainBlue") ?? UIColor.mainBlue
                    cell?.nameLabel.textColor = UIColor.white
                }
            } else {
                
                cell?.shadowImage.image = UIImage(named: "serviceShadow")
                cell?.shadowImage.frame.origin.y = 0

                // imageView.image
                if self.items[indexPath.item].name == "Add" {
                    cell?.imageView.image = UIImage(named: "iconCustomAddG")
                } else {
                    if indexPath.item < 3 {
                        cell?.imageView.image = UIImage(named: "\(self.itemsImage[indexPath.item])G")
                    } else {
                        cell?.imageView.image = UIImage(named: "iconCustomTerminalG")
                    }
                }

                delay(0) {
                    cell?.cellView.backgroundColor = UIColor(named: "CollectionColor")
                    cell?.nameLabel.textColor = UIColor.brownGrey
                }
            }
        }
    }

    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! ServiceiconCollectionViewCell
        cell.nameLabel.text = self.items[indexPath.item].name

        // To set the selected cell background color here
        if currentSelected != nil && currentSelected == indexPath.row {
            self.collectionCell_selected(isSelected: true, cell: cell, indexPath: indexPath)
        } else {
            self.collectionCell_selected(isSelected: false, cell: cell, indexPath: indexPath)
        }

        return cell
    }

    // MARK: collectionView didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.row != previousSelected?.row {
            print("Service Select: \(self.items[indexPath.item].identifier)")

            // For remove previously selection
            if previousSelected != nil {
                let cell = collectionView.cellForItem(at: previousSelected!) as? ServiceiconCollectionViewCell
                self.collectionCell_selected(isSelected: false, cell: cell, indexPath: previousSelected!)
            }

            currentSelected = indexPath.row
            previousSelected = indexPath

            //
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.collectionView.reloadItems(at: [indexPath])

            NotificationCenter.default.post(name: NSNotification.Name.init("ConnectViewonShow"), object: false)
            NotificationCenter.default.post(name: NSNotification.Name.init("NetViewonShow"), object: false)

            if self.lastCollectionID != self.items[indexPath.item].identifier {
                // tap collection action
                switch self.items[indexPath.item].name {
                case "Net Speed":
                    NotificationCenter.default.post(name: NSNotification.Name.init("NetViewonShow"), object: true)
                    self.switchView(showView: self.childNetView)
                case "Connect":
                    NotificationCenter.default.post(name: NSNotification.Name.init("ConnectViewonShow"), object: true)
                    self.switchView(showView: self.childSSView)
                case "Shadowsock":
                    NotificationCenter.default.post(name: NSNotification.Name.init("JSONCall"), object: self.items[indexPath.item])
                    self.switchView(showView: self.childJSONView)
                case "Add":
                    self.switchView(showView: self.childAddView)
                default:
                    NotificationCenter.default.post(name: NSNotification.Name.init("JSONCall"), object: self.items[indexPath.item])
                    self.switchView(showView: self.childJSONView)
                }
            }

            self.lastCollectionID = self.items[indexPath.item].identifier
        }

    }

    // MARK: Switch View

    func switchView(showView: UIView) {

        UIView.animate(withDuration: 0.1, animations: {
            self.childNetView.alpha = 0
            self.childSSView.alpha = 0
            self.childJSONView.alpha = 0
            self.childAddView.alpha = 0

            delay(0) {
                UIView.animate(withDuration: 0.4, animations: {
                    showView.alpha = 1
                })
            }
        })





    }

}
