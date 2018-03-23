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

protocol IdiableObject {
    var id: String { set get }
}


protocol NamedObject  {
    var name: String { set get }    
}



class PoshikCategory: IdiableObject, NamedObject, ImmutableMappable {
    var name: String
    var id: String

    required init(map: Map) throws {
        name = try map.value("name")
        id = try map.value("id")
    }
}
