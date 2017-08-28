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

class MarketParameter: ParameterType, PaginationParameter {
    
    var category: PoshikCategory? {
        didSet {
            if category != nil {
                tag = nil
            }
        }
    }
    
    var tag: String? {
        didSet {
            if tag != nil {
                category = nil
            }
        }
    }
    
    var page: Int = 1
    
    func toJSON() -> [String : Any]? {
        
        var parameters: [String : Any]  = ["page": page]
        if let category = category {
            parameters["category"] = category.id
        } else if let tag = tag {
            parameters["search"] = tag
        }
        
        return parameters
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
    

    var method: HTTPMethod = .get
    var route: String = "favorites"
    
    typealias Parameter = ParameterNone
    typealias Response = FavoritePoshiks
    
}

protocol PaginationParameter {
    var page: Int { get set }
}


class MarketService {
    
    let marketApiService = MarketApiService()
    let categoriesApiService = CategoriesApiService()
    let tagApiService = TagAutocompletionApiService()
    let favoritesApiService = FavoritesApiService()
    
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

protocol Parametrized {
    var parameter: Variable<ParameterType> { get }
    
    func update(parameterValue: ParameterType)
}

class PoshiksFromMarket: ObservableType, Parametrized {
    
    let service = MarketService()
    
    typealias E = [Poshik]
    
    let parameter: Variable<ParameterType>
    
    func subscribe<O:ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return parameter.asObservable()
            .flatMap { [unowned self] in
            self.service.getPoshiks(parameter: $0 as! MarketParameter)
        }
            .map {
            $0.poshiks
        }
        .subscribe(observer)
        
        
    }
    
    init() {
       parameter = Variable<ParameterType>(MarketParameter())
    }
    
    func update(parameterValue: ParameterType) {
        parameter.value = parameterValue
    }
}


