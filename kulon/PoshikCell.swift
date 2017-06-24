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

class PoshikCell: UICollectionViewCell {
    
    @IBOutlet weak var image: RoundedImageView!
    
    var request: URLRequest?
    override func prepareForReuse() {
        
        Alamofire.SessionManager.default.session.getAllTasks { tasks in
            for task in tasks {
                if task.originalRequest == self.request {
                    task.cancel()
                }
            }
        }
        image.af_cancelImageRequest()
        image.image = nil
    }
    
    func configure(with poshik: Poshik) {
        if let request = poshik.requestforImage(withSize: .small) {
            //TODO: Possibly not the best solution, alamofireImage 3.3 may bring better solution, check it release  
//            image.loadGif(url: url)
//            image.image = UIImage.gif(url: url)
//            image.af_setImage(withURLRequest: request)
            self.request = request
            image.setImage(with: request)
        }
    }
}
