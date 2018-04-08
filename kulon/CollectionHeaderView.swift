//
//  CollectionHeaderView.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 23/06/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

class CollectionHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var title: UILabel!
    
    func configure(with title: String) {
        self.title.text = title
    }
}

class CollectionHeaderViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    func configure(with title: String) {
        self.title.text = title
    }
}
