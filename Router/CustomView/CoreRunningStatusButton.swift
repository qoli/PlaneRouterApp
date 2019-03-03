import UIKit

@IBDesignable class CoreRunningStatusButton: UIView {
    
    
    @IBOutlet weak var imageButton: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    @IBInspectable var Name: String = "" {
        didSet {
            setButtonTitle()
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
    var buttonTapped: (UIButton) -> Void = {_ in }
    @IBAction private func tapAction(_ sender: UIButton) {
        buttonTapped(sender)
    }
    
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
    
    // 載入 xib
    var view: UIView!
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: CoreRunningStatusButton.self)
        let nib = UINib(nibName: String(describing: CoreRunningStatusButton.self), bundle: bundle)
        
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    
}
