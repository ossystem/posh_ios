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
    @IBOutlet weak var nextButton: RoundedButton!
    let loginService = LoginService()
    let registrationService = RegistrationService()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.transitioningDelegate = self
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let email = emailField.text,
            let password = passwordField.text
            else { return }
        sender.setWaiting(true)
        let credentials = UserCredentials(email: email, password: password)
        loginService.login(with: credentials)
            .subscribe(onError: { error in
                if error is UserNotExistError {
                    self.tryToCrateNewUrer(with: credentials)
                } else {
                    sender.setWaiting(false)
                    self.showErrorMessage(error)
                }
                print(error.localizedDescription)
            }, onCompleted: {
                self.enterApplication()
            }).addDisposableTo(bag)
    }
    
    @IBAction func backButtonTapped(_ sender: RoundedButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func enterApplication() {
        nextButton.setWaiting(false)
        performSegue(withIdentifier: Identifiers.Segue.MainTabBarViewController, sender: nil)
    }
    
    func tryToCrateNewUrer(with credentials: UserCredentials) {
        let alertController = UIAlertController(title: "Регистрация", message: "Аккаунта с такой почтой не существует. Создать новый?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Ok", style: .default) { [unowned self] (action) in
            self.registrationService.register(with: credentials)
                .subscribe(onError: { error in
                    self.nextButton.setWaiting(false)
                    print(error.localizedDescription)
                }, onCompleted: {
                    self.enterApplication()
                }).addDisposableTo(self.bag)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
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
