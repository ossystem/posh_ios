//
//  UIButton.swift
//  Telemed
//
//  Created by Ivan Grachev on 22/12/2016.
//  Copyright © 2016 Jufy. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setWaiting(_ waiting: Bool, activityIndicatorColor: UIColor? = nil) {
        isEnabled = !waiting
        setTitleColor(waiting ? titleLabel?.textColor.withAlphaComponent(0) : titleLabel?.textColor.withAlphaComponent(1), for: .normal)
        
        if waiting {
            setImage(nil, for: .normal)
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityIndicator.center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
            if let activityIndicatorColor = activityIndicatorColor {
                activityIndicator.color = activityIndicatorColor
            }
            addSubview(activityIndicator)
            activityIndicator.startAnimating()
        } else {
            for subview in subviews {
                if let activityIndicator = subview as? UIActivityIndicatorView {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                }
            }
        }
    }
    
    func with(title: String?, for state: UIControlState = .normal) -> Self {
        self.setTitle(title, for: state)
        return self
    }
    
    //    func with(text: Text, for state: UIControlState = .normal) -> Self {
    //        self.setAttributedTitle(text.toAttributedString(), for: .normal)
    //        return self
    //    }
    
    func with(image: UIImage, for state: UIControlState = .normal) -> Self {
        self.setImage(image, for: state)
        return self
    }
    
    func with(titleColor: UIColor?, for state: UIControlState = .normal) -> Self {
        self.setTitleColor(titleColor, for: state)
        return self
    }
    
    func with(font: UIFont) -> Self {
        self.titleLabel?.font = font
        return self
    }
    
    func with(titleEdgeInsets: UIEdgeInsets) -> Self {
        self.titleEdgeInsets = titleEdgeInsets
        return self
    }
    
    func with(contentEdgeInsets: UIEdgeInsets) -> Self {
        self.contentEdgeInsets = contentEdgeInsets
        return self
    }
    
    func setImageAndTitle(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
    
    func with(contentHorizontalAlignment: UIControlContentHorizontalAlignment) -> Self {
        self.contentHorizontalAlignment = contentHorizontalAlignment
        return self
    }
    
    func with(contentVerticalAlignment: UIControlContentVerticalAlignment) -> Self {
        self.contentVerticalAlignment = contentVerticalAlignment
        return self
    }
    
    func with(tintColor: UIColor) -> Self {
        self.tintColor = tintColor
        return self
    }
}
