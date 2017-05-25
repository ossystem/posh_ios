//
//  FirstViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/04/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    @IBOutlet weak var topBar: TopBarView!
    
    func showErrorMessage(_ error: Error) {
        let message = error.localizedDescription
        let alertController = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}





