//
//  Category.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 16/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import AlamofireObjectMapper
import ObjectMapper

class IdiableObject: ImmutableMappable {
    
    var id: Int = -1
    var name: String = ""
    
    required init(map: Map) throws {
        id <- map["id"]
        name <- map["name"]
    }
}

class PoshikCategory: IdiableObject {
    
}
