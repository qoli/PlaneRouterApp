//
//  App-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/2/18.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Hero

class ServiceiconCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var shadowImage: UIImageView!
}

class App_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: - 
    
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

    var isMenuOpen: Bool = true
    var selectServiceNumber: Int = 0

    var lastPageName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // update
        updateNotes()
        
        // login
        GetRouterCookie()

        self.appTitle.alpha = 0

        collection_init()

        // Notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCollection(_:)),
            name: NSNotification.Name(rawValue: "updateCollection"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(serviceListActionNotification(_:)),
            name: NSNotification.Name(rawValue: "appServiceList"),
            object: nil
        )

        delay(0.6) {
            self.collection_select(selected: 0)
        }
    }

    // MARK: - Notification
    
    @objc func updateCollection(_ notification: Notification) {
        self.collection_update()
        self.collection_select(selected: self.items.count - 1)
    }

    @objc func serviceListActionNotification(_ notification: Notification) {
        serviceListDo((notification.object != nil))
    }

    // MARK: - IBAction
    
    //
    @IBAction func PanSwipeAction(_ sender: UIPanGestureRecognizer) {
        if self.PanSwipe.state == .changed {
            let offY = self.PanSwipe.velocity(in: childViews).y
            if offY <= -150 {
                serviceListDo(true)
            }
            if offY >= 150 {
                serviceListDo(false)
            }
        }
    }

    @IBAction func SettingAction(_ sender: UIButton) {
        self.collectionView.alpha = 0
        self.performSegue(withIdentifier: "goSettingTableSegue", sender: nil)
    }


    //
    @IBAction func serviceListMenuAction(_ sender: UIButton) {
        serviceListDo(self.isMenuOpen)
    }
    
    // MARK: - 
    
    func updateNotes() {
        let updateTimeCacheKey = "updateTime"
        let updateTime = CacheString(Key: updateTimeCacheKey)
        
        fetchRequestString(
            api: "https://raw.githubusercontent.com/qoli/AtomicR/master/Update/updatetime.txt",
            isRefresh: true,
            completionHandler: { value, error in
                print("Update Time Remote: \(value ?? "") · Loacl: \(updateTime)")
                if value != nil {
                    if updateTime != value {
                        self.performSegue(withIdentifier: "goUpdateNotesSegue", sender: nil)
                        _ = CacheString(text: value ?? "", Key: updateTimeCacheKey)
                    }
                }
        })
    }

    func serviceListDo(_ isOpen: Bool) {
        isMenuOpen = isOpen
        // 200 / 60
        if isMenuOpen {
            self.childViewTop.constant = -158
            isMenuOpen = false
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.appTitle.alpha = 1
                self.menuButton.setBackgroundImage(UIImage(named: "iconMenuNormal"), for: .normal)
            })
        } else {
            self.childViewTop.constant = 0
            isMenuOpen = true
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                self.appTitle.alpha = 0
                self.menuButton.setBackgroundImage(UIImage(named: "iconMenuActive"), for: .normal)
            })
        }
    }

    // MARK: - collectionView
    
    // collectionView
    var previousSelected: IndexPath?
    var currentSelected: Int?

    var items: Array = [""]
    let itemsImage = ["iconCustomSpeed", "iconCustomInternetNetwork", "iconCustomShadowsockLogo"]
    let itemsFixed = ["Net Speed", "Connect", "Shadowsock"]

    func collection_select(selected: Int = 0) {
        let indexPath = IndexPath(row: selected, section: 0)
        self.collectionView(self.collectionView, didSelectItemAt: indexPath)
    }

    func collection_init() {

        collectionView.dataSource = self
        collectionView.delegate = self

        collection_update()
        collection_select()
    }

    func collection_update() {
        self.items = self.itemsFixed
        let addList = getServiceList()
        for i in addList {
            items.append(i as! String)
        }
        items.append("Add")
        self.collectionView.reloadData()
    }

    func collectionCell_selected(isSelected: Bool, cell: ServiceiconCollectionViewCell?, indexPath: IndexPath) {
        if cell != nil {
            if isSelected {
                self.selectServiceNumber = indexPath.row
                self.appTitle.text = self.items[self.selectServiceNumber]

                cell?.cellView.backgroundColor = UIColor.mainBlue
                cell?.shadowImage.image = UIImage(named: "serviceShadowActive")
                cell?.shadowImage.frame.origin.y = 6

                // imageView.image
                if self.items[indexPath.item] == "Add" {
                    cell?.imageView.image = UIImage(named: "iconCustomAddW")
                } else {
                    if indexPath.item < self.itemsFixed.count {
                        cell?.imageView.image = UIImage(named: "\(self.itemsImage[indexPath.item])W")
                    } else {
                        cell?.imageView.image = UIImage(named: "iconCustomTerminalW")
                    }
                }

                delay(0) {
                    cell?.nameLabel.textColor = UIColor.white
                }
            } else {
                cell?.cellView.backgroundColor = UIColor.white
                cell?.shadowImage.image = UIImage(named: "serviceShadow")
                cell?.shadowImage.frame.origin.y = 0

                // imageView.image
                if self.items[indexPath.item] == "Add" {
                    cell?.imageView.image = UIImage(named: "iconCustomAddG")
                } else {
                    if indexPath.item < 3 {
                        cell?.imageView.image = UIImage(named: "\(self.itemsImage[indexPath.item])G")
                    } else {
                        cell?.imageView.image = UIImage(named: "iconCustomTerminalG")
                    }
                }

                delay(0) {
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
        cell.nameLabel.text = self.items[indexPath.item]

        // To set the selected cell background color here
        if currentSelected != nil && currentSelected == indexPath.row {
            self.collectionCell_selected(isSelected: true, cell: cell, indexPath: indexPath)
        } else {
            self.collectionCell_selected(isSelected: false, cell: cell, indexPath: indexPath)
        }

        return cell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.row != previousSelected?.row {
            print("Service Select: \(self.items[indexPath.item])")

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

            if self.lastPageName != self.items[indexPath.item] {
                // tap collection action
                switch self.items[indexPath.item] {
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

            self.lastPageName = self.items[indexPath.item]
        }

    }

    func switchView(showView: UIView) {

        self.childNetView.alpha = 0
        self.childSSView.alpha = 0
        self.childJSONView.alpha = 0
        self.childAddView.alpha = 0

        UIView.animate(withDuration: 0.3, animations: {
            showView.alpha = 1
        })

    }

    func loadSubView(vcID: String) {

        for sView in self.childNetView.subviews {
            sView.removeFromSuperview()
        }

        let subview = storyboard?.instantiateViewController(withIdentifier: vcID)
        subview?.view.frame = view.bounds
        subview?.willMove(toParent: self)
        self.childNetView.addSubview(subview!.view)
        subview?.didMove(toParent: self)
    }

}
