//
//  RoundedImageView.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 20/04/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RoundedImageView: UIImageView {
    
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
    
}
