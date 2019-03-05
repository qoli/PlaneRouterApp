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

        // ERROR ExceptionHandler
        if let exception = UserDefaults.standard.object(forKey: "ExceptionHandler") as? [String] {
            
            print("Error was occured on previous session! \n", exception, "\n\n-------------------------")
            var exceptions = ""
            for e in exception {
                exceptions = exceptions + e + "\n"
            }
        }
//        
//        delay {
//            fatalError()
//        }
        
        delay {
            if UserDefaults.standard.bool(forKey: "isApp") {
                self.performSegue(withIdentifier: "goAppSegue", sender: nil)
            } else {
                self.performSegue(withIdentifier: "goWalkSegue", sender: nil)
            }
        }

    }
    
}
