//
//  ServiceStatusView.swift
//  Router
//
//  Created by 庫倪 on 2019/2/7.
//  Copyright © 2019 庫倪. All rights reserved.
//

import UIKit

class ServiceStatusView: UIView {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageButton: UIImageView!
    
    @IBInspectable var Name: String = "" {
        didSet {
            setButtonTitle()
        }
    }
    @IBInspectable var DescText: String = "" {
        didSet {
            setdescriptionLabelText()
        }
    }
    @IBInspectable var Image: UIImage! {
        get {
            return imageButton.image
        }
        set(Image) {
            imageButton.image = Image
        }
    }

    // 曝光 Button 的 IBAction 接口
    var buttonTapped: (UIButton) -> Void = { _ in }

    @IBAction private func tapAction(_ sender: UIButton) {
        buttonTapped(sender)
    }

    // 曝光接口的示範代碼
    // @IBAction private func tapAction(_ sender: UIButton) {
    //     buttonTapped(sender)
    // }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setButtonTitle()
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setButtonTitle()

    }

    func setButtonTitle() {
        self.button.setTitle(Name, for: .normal)
    }
    func setdescriptionLabelText() {
        self.descriptionLabel.text = DescText
    }

    // 載入 xib
    var view: UIView!
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {

        let bundle = Bundle(for: ServiceStatusView.self)
        let nib = UINib(nibName: String(describing: ServiceStatusView.self), bundle: bundle)

        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }

}
