//
//  AuthViewCoontroller.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 03/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import ExternalAccessory

class AuthViewController: BaseViewController {


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
