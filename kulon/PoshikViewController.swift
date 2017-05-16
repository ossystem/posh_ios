//
//  PoshikViewController.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 12/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class PoshikViewController: BaseViewController {
    
    var poshik: Poshik?
    @IBOutlet weak var poshikImage: RoundedImageView!
    
    
    override func viewDidLayoutSubviews() {
        poshikImage.cornerRadius = poshikImage.frame.width/2
    }
}
