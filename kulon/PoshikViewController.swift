//
//  PoshikViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 12/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class PoshikViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    
    var model: PoshikViewModel!
    var poshikService: PoshikService!
    
    @IBOutlet weak var poshikImage: RoundedImageView!    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        poshikImage.image = model.poshik.image
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.transitioningDelegate = self
        poshikService = PoshikService(with: model.poshik.id)
    }
    
    override func viewDidLayoutSubviews() {
        poshikImage.cornerRadius = poshikImage.frame.width/2
    }
    
    @IBAction func topBarButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        //TODO: change button state
        poshikService.like()
    }
    
    @IBAction func buyButtonTapped(_ sender: Any) {
        //TODO: react somehow
        poshikService.buy()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return PoshikDismissAnimator(with: model?.startingFrame ?? poshikImage.frame)
        }
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented == self {
            return PoshikPresentationAnimator(with: model?.startingFrame ?? poshikImage.frame)
        }
        return nil
    }
}
