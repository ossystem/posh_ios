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

protocol IdiableObject: ImmutableMappable {
    var id: Int { set get }
}


protocol NamedObject: ImmutableMappable {
    var name: String { set get }    
}



class PoshikCategory: IdiableObject, NamedObject {
    var name: String = ""
    var id: Int = -1

    required init(map: Map) throws {
        name <- map["name"]
        id <- map["id"]
    }
}
