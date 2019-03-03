//
//  init-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/3/1.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit

class init_ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        delay {
            if UserDefaults.standard.bool(forKey: "isApp") {
                self.performSegue(withIdentifier: "goAppSegue", sender: nil)
            } else {
                self.performSegue(withIdentifier: "goWalkSegue", sender: nil)
            }
        }

    }

}
