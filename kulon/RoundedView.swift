//
//  RoundedView.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 03/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class RoundedView: UIView {
    
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
    
    var blurView: UIVisualEffectView?
    
    @IBInspectable var hasBlur: Bool = false {
        didSet {
            if hasBlur {
                blurView = UIVisualEffectView(frame: self.bounds)
                let blur = UIBlurEffect(style: .light)
                
                blurView?.effect = blur
                self.addSubview(blurView!)
                self.sendSubview(toBack: blurView!)
            } else {
                blurView?.removeFromSuperview()
                blurView = nil
            }
        }
    }
    
}
