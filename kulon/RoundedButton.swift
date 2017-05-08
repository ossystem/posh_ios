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
    

    
    func highlight(_ highlighted: Bool) {
        backgroundColor = .orange
    }

}
