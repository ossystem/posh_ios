//
//  Category.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 16/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

struct PoshikCategory {
    var title: String
    var image: UIImage
    
    static var sampleSet: [PoshikCategory] {
        return [
            PoshikCategory(title: "Art", image: #imageLiteral(resourceName: "icon_settings_culon")),
            PoshikCategory(title: "Pictures", image: #imageLiteral(resourceName: "icon_settings_culon")),
            PoshikCategory(title: "People", image: #imageLiteral(resourceName: "icon_settings_culon")),
            PoshikCategory(title: "На все бабки", image: #imageLiteral(resourceName: "icon_settings_culon")),
        ]
    }
}
