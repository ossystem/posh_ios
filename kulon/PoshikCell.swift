//
//  PoshikCell.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 08/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class PoshikCell: UICollectionViewCell {
    
    @IBOutlet weak var image: RoundedImageView!
    
    func configure(with poshik: Poshik) {
        image.image = poshik.image
    }
}
