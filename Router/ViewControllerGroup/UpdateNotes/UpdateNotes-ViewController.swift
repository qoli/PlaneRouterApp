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
        Alamofire.request("https://raw.githubusercontent.com/qoli/AtomicR/master/Update/Update.md", method: .get)
            .responseString { response in
                switch response.result {
                case .success(let value):
                    let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 13))
                    markdownParser.header.fontIncrease = 1
                    let markdown = value
                    self.text.attributedText = markdownParser.parse(markdown)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
    

    
}
