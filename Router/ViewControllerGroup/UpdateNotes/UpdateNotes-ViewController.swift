//
//  UpdateNotes-ViewController.swift
//  Router
//
//  Created by 庫倪 on 2019/3/3.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit
import Alamofire
import MarkdownKit

class UpdateNotes_ViewController: UIViewController {

    @IBOutlet weak var text: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        getNotes()
    }

    @IBAction func goAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func getNotes() {
        /**
         Request
         get https://raw.githubusercontent.com/qoli/AtomicR/master/Update/Update.md
         */

        // Fetch Request

        fetchRequestString(
            api: "https://raw.githubusercontent.com/qoli/AtomicR/master/Update/Update.md",
            isRefresh: true,
            completionHandler: { value, error in
                if (value != nil) {
                    let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 13))
                    markdownParser.header.fontIncrease = 1
                    let markdown = value
                    self.text.attributedText = markdownParser.parse(markdown ?? "")
                } else {
                    messageNotification(message: error?.localizedDescription ?? "")
                }
            })
    }




}
