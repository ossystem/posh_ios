//
//  MarketTagAutoCompletionService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 20/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import Alamofire

class TagAutocompletionParameter: ParameterType {

    var prefix: String
    
    init(_ prefix: String) {
        self.prefix = prefix
    }
    
    func toJSON() -> [String : Any]? {
        return ["search" : prefix]
    }
}


class MarketTag: IdiableObject, NamedObject, ImmutableMappable {
    
    var name: String = ""
    var id: String = "-1"
    
    required init(map: Map) throws {
        name <- map["value"]
        id <- map["id"]
    }
    
    init() {
        id = "-1"
        name = "Cats"
    }
}

class TagAutocompletions: ResponseType {
    let tags : [MarketTag]
    required init(map: Map) throws {
        tags = try map.value("tags")
    }
    init() {
        tags = [MarketTag()]
    }
}

class TagAutocompletionApiService: ApiService {
    
    static let shared = TagAutocompletionApiService()
    var method: HTTPMethod = .get
    var route: String = "tags"
    
    typealias Parameter = ParameterNone
    typealias Response = TagAutocompletions
}
