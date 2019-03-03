//
//  WalkDone-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/3/1.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit

class WalkDone_ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "isApp")

        delay(1) {
            self.performSegue(withIdentifier: "goAppSegue", sender: nil)
        }
    }

}
