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
    
}
