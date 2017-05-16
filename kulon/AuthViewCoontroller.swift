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

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let manager = EAAccessoryManager.shared()
        manager.showBluetoothAccessoryPicker(withNameFilter: nil) { (error) in
            print(manager.connectedAccessories)
        }
    }
}
