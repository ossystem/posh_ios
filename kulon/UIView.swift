//
//  UIView.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 16/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    func addCornerRadiusAnimation(to: CGFloat, duration: CFTimeInterval)
    {
        let animation = CABasicAnimation(keyPath:"cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.toValue = to
        animation.duration = duration * 10
        self.layer.add(animation, forKey: "cornerRadius")
    }
}
