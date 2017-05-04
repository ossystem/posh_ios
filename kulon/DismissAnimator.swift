//
//  DismissAnimator.swift
//  24U
//
//  Created by Артмеий Шлесберг on 17/11/2016.
//  Copyright © 2016 Jufy. All rights reserved.
//

import Foundation
import UIKit

class RegistrationDismissAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromController = transitionContext.viewController(forKey: .from)
        if let toController = transitionContext.viewController(forKey: .to) as? AuthViewController {

            UIView.animate(withDuration: 0.3,
                           animations: {
                            fromController?.view.alpha = 0
                            toController.view.subviews[1].subviews.forEach {
                                if !($0 is UIVisualEffectView) {
                                    $0.alpha = 1.0
                                } else {
                                    ($0 as! UIVisualEffectView).effect = nil
                                }
                            }
            } ,
                           completion: { finished in
                            transitionContext.completeTransition(finished)
            })
        } else {
            transitionContext.completeTransition(true)
        }
        
    }
    
}
