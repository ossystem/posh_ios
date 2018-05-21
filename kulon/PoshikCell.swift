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
import Alamofire
import FLAnimatedImage
import SDWebImage

class PoshikCell: UICollectionViewCell {
    
    @IBOutlet weak var image: FLAnimatedImageView!
    
    var request: URLRequest?
    override func prepareForReuse() {
        image?.image = nil
    }

    func configure(with artwork: Artwork) {
        image.image = nil
        image.sd_setImage(with: URL(string: artwork.image.link)!)
    }
}
