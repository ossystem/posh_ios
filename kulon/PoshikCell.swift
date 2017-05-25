//
//  PoshikCell.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 08/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class PoshikCell: UICollectionViewCell {
    
    @IBOutlet weak var image: RoundedImageView!
    
    override func prepareForReuse() {
        image.af_cancelImageRequest()
        image.image = nil
    }
    
    func configure(with poshik: Poshik) {
        //TODO: use different sizes
        if let url = poshik.imageURL {
            image.af_setImage(withURL: url)
        }
    }
}
