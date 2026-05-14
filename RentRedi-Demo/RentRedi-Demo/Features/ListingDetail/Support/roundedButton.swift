import UIKit

@IBDesignable
final class roundedButton: UIButton {

    @IBInspectable var rounded: Bool = false {
        didSet { setNeedsLayout() }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if rounded {
            layer.cornerRadius = min(bounds.width, bounds.height) / 2
            clipsToBounds = true
        } else {
            layer.cornerRadius = 0
        }
    }
}
