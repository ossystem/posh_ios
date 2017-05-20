//
//  CategoriesService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 20/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift
import Alamofire

class PoshikCategories: ResponseType  {
    var categories: [PoshikCategory]
    
    required init(map: Map) throws {
        categories = try map.value("categories")
    }
}

class CategoriesApiService : ApiService {
    static let shared = CategoriesApiService()
    
    var method: HTTPMethod = .get
    var route: String = "categories"
    
    typealias Parameter = ParameterNone
    typealias Response = PoshikCategories
}
