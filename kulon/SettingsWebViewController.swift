//
//  SettingsWebView.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 22/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class SettingsWebViewController : BaseViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var request: URLRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(request)
    }

    @IBAction func topButtonTapped(_ sender: RoundedButton) {
        dismiss(animated:true, completion: nil)
    }
}
