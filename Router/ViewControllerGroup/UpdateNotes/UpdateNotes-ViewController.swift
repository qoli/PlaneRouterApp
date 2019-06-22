//
//  UpdateNotes-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/3/3.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Alamofire
import Chrysan

class UpdateNotes_ViewController: UIViewController {

    @IBOutlet weak var updateTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.chrysan.show(.running, message: nil, hideDelay: 1)
        
        getUpdateNotes()
    }

    @IBAction func goAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func getUpdateNotes() {
        fetchRequestString(
            api: "https://raw.githubusercontent.com/qoli/AtomicR/master/Update/changelog.txt",
            isRefresh: true,
            completionHandler: { value, error in
                if (value != nil) {
                    self.updateTextView.text = "\(value ?? "Update Notes")"
                } else {
                    self.chrysan.show(.error, message: error?.localizedDescription, hideDelay: 2)
                }
            })
    }




}
