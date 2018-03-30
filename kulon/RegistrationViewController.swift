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
import RxCocoa

class RegistrationViewController: BaseViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nextButton: RoundedButton!
    let loginService = LoginService()
    let registrationService = RegistrationService()
    let bag = DisposeBag()
    
    @IBOutlet weak var sendCodeButton: RoundedButton!
    @IBOutlet var codeViewsGroup: [UIView]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.transitioningDelegate = self
    
        
        let firstObs = sendCodeButton.rx.tap
            .map { [unowned self] in self.emailField.text }
            .filter {
                $0 != nil && $0 != ""
            }
            .map { UserPhoneNumber(with: $0!) }
            .do(onNext: { _ in
                self.sendCodeButton.setWaiting(true)
            })
            .flatMap { [unowned self] in
                 self.loginService.auth(with: $0)
            }
            .do(onNext: { [unowned self] _ in
                self.sendCodeButton.setWaiting(false)
                self.showCodeField()
            })

        Observable.combineLatest(
            firstObs,
            nextButton.rx.tap
                .map { [unowned self] in self.passwordField.text }
                .filter {
                    $0 != nil && $0 != ""
                }
        )
        .flatMap {
            return self.loginService.login(with: UserCredentials(phone: $0, password: $1!))
        }
        .subscribe(onNext: { 
            self.enterApplication()
        })
        .disposed(by: bag)
        
        //add another button to use fro commiting code, show only afte
    }
    
    func showCodeField() {
        //expand
        UIView.animate(withDuration: 0.4) {
            self.sendCodeButton.isHidden = true
            self.codeViewsGroup.forEach {
                $0.isHidden = false
            }
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "VKlogin":
            (segue.destination as! SocialWebViewController).socialNetwork = .vkontakte
        case "FBlogin":
            (segue.destination as! SocialWebViewController).socialNetwork = .facebook
        default:
            return
        }
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
