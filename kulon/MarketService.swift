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
    
    var category: IdiableObject? {
        didSet {
            if category != nil {
                tag = nil
                artist = nil
            }
        }
    }
    
    var tag: IdiableObject? {
        didSet {
            if tag != nil {
                category = nil
                artist = nil
            }
        }
    }
    
    var artist: IdiableObject? {
        didSet {
            if artist != nil {
                category = nil
                tag = nil
            }
        }
    }
    
    var page: Int = 1
    
    func toJSON() -> [String : Any]? {
        
        var parameters: [String : Any]  = ["page": page]
        if let category = category {
            parameters["category"] = category.id
        } else if let tag = tag {
            parameters["search"] = tag.id
        } else if let artist = artist {
            parameters["artist"] = artist.id
        }
        
        return parameters
    }
}

class ObservableMarketParameter: ObservableType {
    
    typealias E = MarketParameter
    
    private var publisSubject: PublishSubject<MarketParameter> = PublishSubject<MarketParameter>()
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, ObservableMarketParameter.E == O.E {
        return publisSubject.startWith(MarketParameter()).subscribe(observer)
    }
    
    func update(_ parameter: MarketParameter) {
        publisSubject.onNext(parameter)
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
    var poshiks: [FavoritePoshik]
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


class ArtistFromJSON: Artist, ResponseType {
    
    var id: String
    var name: String
    var avatar: ObservableImage
    
    required init(map: Map) throws {
        id = try map.value("id")
        name = try map.value("name")
        do {
            avatar = try map.value("avatar") as ObservableImageFromJSON
        } catch {
            avatar = FakeEmptyObservableImage()
        }
    }
    
    init() {
        id = "-1"
        name = "Shlesberg"
        avatar = FakeEmptyObservableImage()
    }
}

class ArtistsFromApi : ResponseType  {
    var artists: [Artist]
    
    init() {
        artists = [ArtistFromJSON()]
    }
    
    required init(map: Map) throws {
        artists = try map.value("artists") as [ArtistFromJSON]
    }
}

class ArtistsApiService: ApiService {
    
    typealias Parameter = ParameterNone
    typealias Response = ArtistsFromApi
    
    var method: HTTPMethod = .get
    var route: String = "artists"
}


class MarketService {
    
    let marketApiService = MarketApiService()
    let categoriesApiService = CategoriesApiService()
    let tagApiService = TagAutocompletionApiService()
    let favoritesApiService = FavoritesApiService()
    let artistsApiService = ArtistsApiService()
    
    func getPoshiks(parameter: MarketParameter) -> Observable<MarketPoshiks> {
        return marketApiService.request(parameter: parameter)
    }
    
    func getCategories() -> Observable<PoshikCategories> {
        return categoriesApiService.request(parameter: ParameterNone())
    }
    func getArtists() -> Observable<ArtistsFromApi> {
        return artistsApiService.request(parameter: ParameterNone())
    }
    func getTags() -> Observable<TagAutocompletions> {
        return tagApiService.request(parameter: ParameterNone())
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


