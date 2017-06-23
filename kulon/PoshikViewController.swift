//
//  PoshikViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 12/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class PoshikViewController: BaseViewController, UIViewControllerTransitioningDelegate {
    
    var model: PoshikViewModel!
    var poshikService: PoshikService!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var poshikImage: RoundedImageView!    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var rightButton: RoundedButton!
    @IBOutlet weak var leftButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let request = model.poshik.requestforImage(withSize: .middle) {
            poshikImage.setImage(with: request)
//            poshikImage.af_setImage(withURLRequest: request)
        }
        
        setupButtons()
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.transitioningDelegate = self
        poshikService = PoshikService(with: model.poshik)
    }
    
    func setupButtons() {
        //TODO: refactor, setup buttons by poshik
        
        var leftImage: UIImage
        if model.poshik is MyPoshikUploaded {
            leftImage = #imageLiteral(resourceName: "icon_top_trash")
        } else {
            leftImage = model.poshik.isLiked ? #imageLiteral(resourceName: "icon_like") : #imageLiteral(resourceName: "icon_like_1")
        }
        leftButton.setImage(leftImage, for: .normal)
        
        if model.poshik is MyPoshikFromMarket {
            leftButton.isHidden = true
        }
        
        var rightImage: UIImage
        if model.poshik.isPurchased || model.poshik is MyPoshikFromMarket {
            rightImage = #imageLiteral(resourceName: "icon_install")
        } else {
            rightImage = #imageLiteral(resourceName: "icon_buy")
        }
        rightButton.setImage(rightImage, for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        poshikImage.cornerRadius = poshikImage.frame.width/2
    }
    
    @IBAction func topBarButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likeButtonTapped(_ sender: RoundedButton) {
        //TODO: change button state
        if model.poshik is PoshikFromMarket {
            poshikService.like().subscribe(onNext: { _ in
                self.model.poshik.isLiked = !self.model.poshik.isLiked
                self.setupButtons()
            }, onError: { error in
                self.showErrorMessage(error)
            }).disposed(by: disposeBag)
        } else {
            poshikService.delete().subscribe(onNext: { _ in
                self.dismiss(animated: true, completion: nil)
            }, onError: { error in
                self.showErrorMessage(error)
            }).disposed(by: disposeBag)
        }
    }
    
    @IBAction func buyButtonTapped(_ sender: RoundedButton) {
        //TODO: react somehow
        if !model.poshik.isPurchased {
            poshikService.buy().subscribe(onNext: { _ in
                sender.backgroundColor = .red
            }, onError: { error in
                self.showErrorMessage(error)
            }).disposed(by: disposeBag)
        }
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
