//
//  CategoryCell.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 16/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class CategoryCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: RoundedImageView!
    
    func configure(with category: PoshikCategory) {
        title.text = category.name
        
    }
}
