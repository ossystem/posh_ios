//
//  SocialWebViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 11/07/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SafariServices
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RxSwift

class SocialWebViewController : UIViewController, UIWebViewDelegate {
    
    let disposeBag = DisposeBag()
    let service = SocialService()
    var socialNetwork: SocialAuthProvider!
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        webView.delegate = self
        service.requestLogin(with: socialNetwork)
            .subscribe(onNext: { [unowned self] link in
                self.webView.loadRequest(URLRequest(url: URL(string: link.loginLink)!))
        })
        .disposed(by: disposeBag)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
   //FIXME: GUARD forcecasts
        guard
            let data = URLCache.shared.cachedResponse(for: webView.request!)?.data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = json?["data"] as? [String: Any]
            else { return }
        
        let map = Map(mappingType: .fromJSON, JSON: content)
        guard let authResult = try? AuthResult(map: map)
            else {
                showAuthError()
                return
            }
        
        TokenService().token = authResult.token
        UserCredentialsService().isLoggedIn = true
        
        performSegue(withIdentifier: Identifiers.Segue.MainTabBarViewController, sender: nil)

        
    }

    func showAuthError() {
        
    }
}
