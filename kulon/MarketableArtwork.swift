//
//  MarketableArtwork.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 03/04/2018.
//  Copyright © 2018 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import Alamofire

protocol MarketableArtwork: Artwork, Purchasable, Selectable {
    func acquire() -> Observable<Acquisition>
    func like() -> Observable<Bool>
    var purchaseSubject : PublishSubject<Void> { get }
    
}

extension MarketableArtwork {
    var viewControllerToPresentt: UIViewController {
        return MarketableArtworkController(marketableArtwork: self)
    }
}

protocol Purchase: NamedObject {
    var image: ObservableImage { get }
}

class PurchaseFromJSON: Purchase, ResponseType {
    var image: ObservableImage
    
    var name: String
    
    required init(map: Map) throws {
        image = try map.value("image") as ObservableImageFromJSON
        name = try map.value("name")
    }
    
}

class FakeMarketableArtwork: MarketableArtwork {
    
    var isLiked: Bool = false
    
    
    var purchased: Observable<Void> {
        return purchaseSubject.asObservable()
    }
    
    var purchaseSubject = PublishSubject<Void>()
    
    func acquire() -> Observable<Acquisition> {
        return Observable.just(FakeAqcuisition())
    }
    
    func like() -> Observable<Bool> {
        return Observable<Bool>.never()
    }
    
    var image: ArtworkImage = FakeArtworkImage()
    
    var id: String = "-1"
    
    var name: String = "Perfect"
    
        var isPurchased: Bool = false
    
    var info: Observable<ArtworkInfo> {
        return Observable.just(FakeArtworkInfo())
    }
    
}




class MarketableArtworkFromArtwork: MarketableArtwork {
    var isLiked: Bool {
        return origin.isLiked
    }
    
    func like() -> Observable<Bool> {
        return origin.like()
    }
    
    var id: String
    
    var name: String
        
    
    func acquire() -> Observable<Acquisition> {
        return info.flatMap { ObservableAcquisitionFromAPI(artworkInfo: $0).asObservable() }
    }
    
    var info: Observable<ArtworkInfo> {
        return origin.info
    }
    
    var image: ArtworkImage {
        return origin.image
    }
    
    var purchased: Observable<Void> {
        return purchaseSubject.asObservable()
    }
    
    var isPurchased: Bool {
        return origin.isPurchased
    }
    
    var purchaseSubject = PublishSubject<Void>()
    
    private var origin: Artwork
    
    init(artwork: Artwork) {
        self.origin = artwork
        self.name = artwork.name
        self.id = artwork.id
    }
}

class FakePurchase: Purchase {
    var name: String = "Monalisa"
    
    var image: ObservableImage = FakeObservableImage()
}

protocol MarketableArtworks {
    func asObservable() ->  Observable<[MarketableArtwork]>
}

class FakeMarketableArtworks: MarketableArtworks {
    func asObservable() -> Observable<[MarketableArtwork]> {
        return Observable.just([FakeMarketableArtwork()])
    }
}

class MarketableArtworksFromAPI: MarketableArtworks {
    
    private var parameter: MarketParameter
    private var service = MarketArtworksApiService()
    
    func asObservable() -> Observable<[MarketableArtwork]> {
        return service.request(parameter: parameter).map {
            $0.artworks.map { MarketableArtworkFromArtwork(artwork: $0) }
        }
    }
    
    init(parameter: MarketParameter) {
        self.parameter = parameter
    }
    
}

class MarketArtworksApiService: ApiService {
    
    typealias Parameter = MarketParameter
    typealias Response = ArtworksFromJSON
    
    var route: String = "artworks"
    var method: Alamofire.HTTPMethod = .get
}


class LikedArtworksFromAPI: MarketableArtworks {
    func asObservable() -> Observable<[MarketableArtwork]> {
        return LikedArtworksApiService().request(parameter: ParameterNone()).map {
            $0.artworks.map { MarketableArtworkFromArtwork(artwork: $0) }
        }
    }
}

class LikedArtworksApiService: ApiService {
    
    typealias Parameter = ParameterNone
    typealias Response = ArtworksFromJSON
    
    var route: String = "artworks/favorites"
    var method: Alamofire.HTTPMethod = .get
}
