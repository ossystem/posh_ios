//
//  RegistrationViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 03/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class RegistrationViewController: BaseViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    let loginService = LoginService()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.transitioningDelegate = self
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let email = emailField.text,
            let password = passwordField.text
            else { return } //TODO: show alert
        let credentials = UserCredentials(email: email, password: password)
        loginService.login(with: credentials)
            .subscribe(onError: { error in
                print(error.localizedDescription)
            }, onCompleted: {
                self.enterApplication()
            }).addDisposableTo(bag)
    }
    
    @IBAction func backButtonTapped(_ sender: RoundedButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func enterApplication() {
        performSegue(withIdentifier: Identifiers.Segue.MainTabBarViewController, sender: nil)
    }
}


extension RegistrationViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return RegistrationDismissAnimator()
        }
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented == self {
            return RegistrationPresentationAnimator()
        }
        return nil
    }
}
