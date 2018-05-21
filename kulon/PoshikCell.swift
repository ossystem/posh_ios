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
import SnapKit
class PoshikCell: UICollectionViewCell {
    
    @IBOutlet weak var image: FLAnimatedImageView!
    private lazy var loadingIndicator = { [unowned self] () -> UIActivityIndicatorView in
        let ind = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ind.hidesWhenStopped = true
        self.addSubview(ind)
        ind.snp.makeConstraints {
            $0.center.equalTo(self.image)
        }
        return ind
    }()
    
    var request: URLRequest?
    override func prepareForReuse() {
        image?.image = nil
    }

    func configure(with artwork: Artwork) {
        image.image = nil
        loadingIndicator.startAnimating()
        image.sd_setImage(with: URL(string: artwork.image.link)!) { [weak self] im, er, cache, url in
            if let error = er {
                print("Error image loading for URL: \(String(describing: url)) Message: \(error)")
            }
            self?.loadingIndicator.stopAnimating()
        }
    }
}
