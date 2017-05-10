//
//  LikeView.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 10/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class LikeView: UIImageView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.image = #imageLiteral(resourceName: "image_like")
        self.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = #imageLiteral(resourceName: "image_like")
        self.contentMode = .scaleAspectFit
    }
    
    func animateLike() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
            self.frame = self.frame.insetBy(dx: 100, dy: 100)
        }) { completed in
            UIView.animate(withDuration: 0.1, animations: {
                self.frame = self.frame.insetBy(dx: -10, dy: -10)
            }, completion: { completed in
                UIView.animate(withDuration: 0.1, animations: {
                    self.frame = self.frame.insetBy(dx: -90, dy: -90)
                    self.alpha = 0
                })
            })
            
        }
    }
}
