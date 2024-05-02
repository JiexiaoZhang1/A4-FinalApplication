import Foundation
import UIKit

/// A custom UIView designed to display rounded corners and drop shadows, making it reusable and configurable from Interface Builder.
@IBDesignable
class RoundCircleClass: UIView {
    /// The corner radius of the view. Setting this property will round the corners of the UIView.
    @IBInspectable var radius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = true
            self.clipsToBounds = true
        }
    }

    /// The color of the shadow. Changing this value will update the shadow color of the view's layer.
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }

    /// The opacity of the shadow. Adjusting this value will change the transparency of the shadow, where 1 is opaque and 0 is transparent.
    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }

    /// The blur radius of the shadow. A larger value will create a more diffuse shadow.
    @IBInspectable var shadowRadius: CGFloat = 2.0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }

    /// The offset of the shadow from the view. Positive values move the shadow down and to the right, while negative values move it up and to the left.
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 2) {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }

    /// Called when the view is loaded from an Interface Builder storyboard or XIB.
    override func awakeFromNib() {
        super.awakeFromNib()
        // Apply shadow settings to ensure they are visible in the runtime environment.
        applyShadow()
    }

    /// Called when the view is being prepared to be displayed in Interface Builder.
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        // Apply shadow to make sure that the view appears correctly in the Interface Builder.
        applyShadow()
    }

    /// Applies the shadow properties to the view's layer. This function centralizes the shadow application logic to ensure consistency in appearance.
    private func applyShadow() {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOffset = shadowOffset
    }
}
