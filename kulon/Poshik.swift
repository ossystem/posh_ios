//
//  Poshik.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 08/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit

struct Poshik {
    var image: UIImage
    
    static var sampleSet: [Poshik] {
        return [
            Poshik(image: #imageLiteral(resourceName: "sample_poshik_1")),
            Poshik(image: #imageLiteral(resourceName: "sample_poshik_5")),
            Poshik(image: #imageLiteral(resourceName: "sample_poshik_3")),
            Poshik(image: #imageLiteral(resourceName: "sample_poshik_2")),
            Poshik(image: #imageLiteral(resourceName: "sample_poshik_4"))
        ]
    }
}
