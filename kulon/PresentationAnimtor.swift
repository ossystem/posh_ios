//
//  PresentationAnimtor.swift
//  24U
//
//  Created by Артмеий Шлесберг on 17/11/2016.
//  Copyright © 2016 Jufy. All rights reserved.
//

import Foundation
import UIKit

class RegistrationPresentationAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toController = transitionContext.viewController(forKey: .to) as! RegistrationViewController
        if let fromController = transitionContext.viewController(forKey: .from) as? AuthViewController {
            let container = transitionContext.containerView
            container.addSubview((toController.view)!)
            toController.view.subviews[0].subviews.forEach {
                if !($0 is UIVisualEffectView) {
                    $0.alpha = 0.0
                } else {
                    ($0 as! UIVisualEffectView).effect = nil
                }
            }
            
            UIView.animate(withDuration: 0.3,
                           animations: { 
                            toController.view.subviews[0].subviews.forEach {
                                if !($0 is UIVisualEffectView) {
                                    $0.alpha = 1.0
                                } else {
                                     ($0 as! UIVisualEffectView).effect = UIBlurEffect(style: UIBlurEffectStyle.light)
                                }
                            }
                            fromController.view.subviews[1].subviews.forEach {
                                    if !($0 is UIVisualEffectView) {
                                        $0.alpha = 0.0
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
