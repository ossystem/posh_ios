//
//  Poshik.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 08/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

struct Poshik: ImmutableMappable {
    
    var imageURLString: String = ""
    var id: Int = -1
    var imageURL: URL? {
        return URL(string: imageURLString)
    }
    
    init(map: Map) throws {
        imageURLString <- map["image"]
        id <- map["id"]
    }

}
