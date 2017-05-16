//
//  PoshikPresentationAnimator.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 16/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class PoshikAnimator: NSObject  {
    
    let animationDuration = 0.2
    var smallPoshikFrame: CGRect
    
    init(with poshikFrame: CGRect) {
        self.smallPoshikFrame = poshikFrame
        super.init()
    }
    
}

class PoshikPresentationAnimator: PoshikAnimator, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let poshikController = transitionContext.viewController(forKey: .to) as! PoshikViewController
        let blurView = poshikController.blurView
        let container = transitionContext.containerView
        let image = poshikController.poshikImage
        let topbar = poshikController.topBar
        image?.alpha = 0
        topbar?.alpha = 0
        container.addSubview((poshikController.view)!)
        blurView?.effect = nil
        UIView.animate(withDuration: animationDuration, animations: {
            blurView?.effect = UIBlurEffect(style: .dark)
            image?.alpha = 1
            topbar?.alpha = 1
        }, completion: { fineshed in
            transitionContext.completeTransition(fineshed)
        })
    }
}

class PoshikDismissAnimator: PoshikAnimator, UIViewControllerAnimatedTransitioning {
    

    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let poshikController = transitionContext.viewController(forKey: .from) as! PoshikViewController
        let blurView = poshikController.blurView
        let image = poshikController.poshikImage
        let topbar = poshikController.topBar
       
        UIView.animate(withDuration: animationDuration, animations: {
            blurView?.effect = nil
            image?.alpha = 0
            topbar?.alpha = 0
        }, completion: { fineshed in
            transitionContext.completeTransition(fineshed)
        })
    }
}
