//
//  RedactorViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 10/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class RedactorViewController: BaseViewController {
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func topBarButtonTapped(_ sender: RoundedButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
