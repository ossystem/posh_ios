//
//  UIWindow.swift
//  Telemed
//
//  Created by Ivan Grachev on 23/12/2016.
//  Copyright © 2016 Jufy. All rights reserved.
//

import UIKit

extension UIWindow {
    
    func replaceRootViewControllerWith(_ replacementController: UIViewController) {
        if rootViewController?.presentedViewController != nil {
            let snapshotImageView = snapshotView(afterScreenUpdates: false)
            addSubview(snapshotImageView!)
            rootViewController?.dismiss(animated: false) {
                self.rootViewController = replacementController
                self.bringSubview(toFront: snapshotImageView!)
                snapshotImageView?.removeFromSuperview()
            }
        } else {
            rootViewController = replacementController
        }
    }
    
}
