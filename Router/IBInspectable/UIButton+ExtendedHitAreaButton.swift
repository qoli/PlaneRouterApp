import UIKit

class ExtendedHitAreaButton: UIButton {
    
    @IBInspectable var hitAreaExtensionSize: CGSize = CGSize(width: -10, height: -10)
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let extendedFrame: CGRect = bounds.insetBy(dx: hitAreaExtensionSize.width, dy: hitAreaExtensionSize.height)
        
        return extendedFrame.contains(point) ? self : nil
    }
}
