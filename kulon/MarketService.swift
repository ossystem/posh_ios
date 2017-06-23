//
//  MarketService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RxSwift

class MarketParameter: ParameterType {
    
    var category: PoshikCategory? {
        didSet {
            tag = nil
        }
    }
    var tag: String? {
        didSet {
            category = nil
        }
    }
    
    func toJSON() -> [String : Any]? {
        if let category = category {
            return ["category" : category.id]
        } else if let tag = tag {
            return ["tag" : tag]
        } else {
            return nil
        }
    }
}

class MarketPoshiks: ResponseType {
    
    var poshiks: [PoshikFromMarket] = []
    
    subscript(index: Int) -> Poshik {
        return poshiks[index]
    }
    
    required init(map: Map) throws {
        poshiks = try map.value("marketPoshiks")
    }
        
}


class MarketApiService : ApiService {
    
    static let shared = MarketApiService()
    
    typealias Parameter = MarketParameter
    typealias Response = MarketPoshiks
    
    var method: HTTPMethod = .get
    var route: String = "market"
    
}

class FavoritePoshiks: ResponseType {
    var poshiks: [Poshik]
    required init(map: Map) throws {
        poshiks = try map.value("favorites")
    }
}

class FavoritesApiService: ApiService {
    
    static let shared = FavoritesApiService()

    var method: HTTPMethod = .get
    var route: String = "favorites"
    
    typealias Parameter = ParameterNone
    typealias Response = FavoritePoshiks
    
}


class MarketService {
    
    let marketApiService = MarketApiService.shared
    let categoriesApiService = CategoriesApiService.shared
    let tagApiService = TagAutocompletionApiService.shared
    let favoritesApiService = FavoritesApiService.shared
    
    func getPoshiks(parameter: MarketParameter) -> Observable<MarketPoshiks> {
        return marketApiService.request(parameter: parameter)
    }
    
    func getCategories() -> Observable<PoshikCategories> {
        return categoriesApiService.request(parameter: ParameterNone())
    }
    
    func getAutocompletedTagsFor(string: String) -> Observable<TagAutocompletions> {
        return tagApiService.request(parameter: TagAutocompletionParameter(string))
    }
    
    func getFavoritePoshiks() -> Observable<FavoritePoshiks> {
        return favoritesApiService.request(parameter: ParameterNone())
    }
    
}
