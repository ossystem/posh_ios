//
//  RedactorViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 10/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import IMGLYColorPicker
import RxGesture
import RxSwift


class RedactorViewController: BaseViewController, RedactorTextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var newPoshikView: RoundedView!
    //TODO: resize poshik to fit space between top bar and keyboard
    let stepBag = DisposeBag()
    
    @IBOutlet weak var textView: RedactorTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.redactorDelegate = self
        textView.becomeFirstResponder()
        configureGestures()
    }
    
    @IBAction func topBarButtonTapped(_ sender: RoundedButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - redactorTextField delegate
    
    func redactorTextField(_ redactorTextField: RedactorTextField, didSelectBackground color: UIColor) {
        newPoshikView.backgroundColor = color
    }
    
    func completeCreatingImage() {
        renderImage()
    }
    
    private func renderImage() {
        textView.resignFirstResponder()
        //In future possible to use UIGraphicsImageRenderer
        UIGraphicsBeginImageContextWithOptions(newPoshikView.frame.size, newPoshikView.isOpaque, 0)
        newPoshikView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newPoshikImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //TODO: send image
        UIImageWriteToSavedPhotosAlbum(newPoshikImage!, nil, nil, nil)
        textView.becomeFirstResponder()
    }
    
    private func configureGestures() {
        view.rx.panGesture().when(.changed)
            .subscribe(onNext: { [weak self] sender in
                let translation = sender.translation(in: self?.textView)
                sender.setTranslation(CGPoint.zero, in: self?.textView)
                self?.textView.transform = (self?.textView.transform.translatedBy(x: translation.x, y: translation.y))!
            }).addDisposableTo(stepBag)
        
        view.rx.pinchGesture().when(.changed)
            .subscribe(onNext: { [weak self] sender in
                self?.textView.font = self?.textView.font?.withSize(self!.textView.font!.pointSize * sender.scale)
                self?.textView.frame.applying(CGAffineTransform(scaleX: sender.scale, y: sender.scale))
                sender.scale = 1
            }).addDisposableTo(stepBag)
        
        view.rx.rotationGesture().when(.changed)
            .subscribe(onNext: { [weak self] sender in
                self?.textView.transform = self!.textView.transform.rotated(by: sender.rotation)
                sender.rotation = 0
            }).addDisposableTo(stepBag)
    }
    
}


