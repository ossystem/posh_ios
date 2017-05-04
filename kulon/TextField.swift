//
//  TextField.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 04/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit


extension UITextField {
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}
