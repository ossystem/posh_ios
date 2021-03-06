//
//  RoundedButton.swift
//  Telemed
//
//  Created by Ivan Grachev on 25/10/2016.
//  Copyright © 2016 Jufy. All rights reserved.
//

import UIKit

@IBDesignable public class RoundedButton: UIButton {
        
    public override func didMoveToSuperview() {
        imageView?.contentMode = .scaleAspectFit
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var underlined: Bool = false {
        didSet {
            if underlined {
                let string  = NSAttributedString(string: self.titleLabel!.text!, attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
                self.setAttributedTitle(string, for: .normal)
            }
        }
    }
    
    @IBInspectable var hasShadow: Bool = false {
        didSet {
            if hasShadow {
                layer.shadowOpacity = 0.1
                layer.shadowRadius = 3
                layer.shadowOffset = CGSize(width: 0, height: 0)
            }
        }
    }
    
    var selectionRadius: CGFloat = 5
    private var externalBorder: CALayer!
    var highlightImage: UIImage?
    var ordinaryImage: UIImage?
    
    func highlight(_ highlighted: Bool) {
        if highlighted {
            if let image = highlightImage {
                setImage(image, for: .normal)
            }
            addExternalBorder()
        } else {
            removeExternalBorder()
            if let image = ordinaryImage {
                setImage(image, for: .normal)
            }
        }
    }
        
    private func addExternalBorder() {
        externalBorder = CALayer(layer: layer)
        externalBorder.frame = CGRect(x: -selectionRadius, y: -selectionRadius, width: frame.width + selectionRadius * 2, height: frame.height + selectionRadius * 2)
        externalBorder.backgroundColor = UIColor.clear.cgColor
        externalBorder.borderWidth = selectionRadius
        externalBorder.cornerRadius = externalBorder.frame.width/2
        externalBorder.borderColor = UIColor.white.cgColor
        clipsToBounds = false
        layer.insertSublayer(externalBorder, at: 0)
    }
    
    private func removeExternalBorder() {
        externalBorder?.removeFromSuperlayer()
    }
    
    static func button(with icon: UIImage, highlightIcon: UIImage? = nil, target: Any?,  action: Selector) -> RoundedButton {
        let button = RoundedButton()
        button.setImage(icon, for: .normal)
        button.ordinaryImage = icon
        button.highlightImage = highlightIcon
        button.backgroundColor = .white
        button.addTarget(target, action: action, for: .touchUpInside)
        return button
    }

}
