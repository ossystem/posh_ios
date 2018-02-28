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
    
    func configure(with category: NamedObject) {
        title.text = category.name
    }
}
