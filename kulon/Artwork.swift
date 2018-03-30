//
//  Artwork.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 21/03/2018.
//  Copyright © 2018 Jufy. All rights reserved.
//

import Foundation
import RxSwift

protocol Artwork: IdiableObject, NamedObject {
    var info: Observable<ArtworkInfo> { get }
    var image: ArtworkImage { get }
}

protocol OwnedArtwork: Artwork {
    func setToDevice() -> Observable<Void> //FIXME: TEMP
}

protocol MarketableArtwork: Artwork {
    func acquire() -> Observable<Acquisition>
    func like() -> Observable<Void>
    //FIXME: it is temp to update "buy" button. Develop architecture to hold this process
    var purchased: Observable<Void> { get }
}

protocol Acquisition {

    var price: Float { get }
    var purchase_params: [String: Any] { get }
    var purchasable: Purchasable { get }
    var seller: Artist { get } //FIXME: TEMP

    func purchase() -> Observable<Void>
    
}

protocol Purchasable: NamedObject {
    var image: ObservableImage { get } 
}

protocol ArtworkInfo: NamedObject {
    var min_price: Int { get }
    var acquisition_params: [String: Any] { get }
    var image: ArtworkImage { get }
    var artist: Artist { get }
    var formats: [ArtworkFormat] { get }
}

protocol ArtworkImage {
    var link: String { get }
    var height: Float { get }
    var width: Float { get }
    var mime: String { get }
}

protocol Artist: IdiableObject, NamedObject {
    var avatar: ObservableImage { get }
}

protocol ArtworkFormat: IdiableObject {
    var deviceCode: String {get}
}

class FakeArtworkInfo: ArtworkInfo {
    var name: String = "Jaconda"
    
    var min_price: Int = 29
    
    var acquisition_params: [String : Any] = [
        "id": "8a5674eb-b26d-484a-8c87-841cb0492694",
        "type": "artwork"
    ]
    
    var image: ArtworkImage = FakeArtworkImage()
    
    var artist: Artist = ArtistFromJSON()
    
    var formats: [ArtworkFormat] = []
    
}

class FakeArtworkImage: ArtworkImage {
    var link: String = "https://www.cats-british.ru/files/articles/koshka_smotrit_v_glaza.jpg"
    
    var height: Float = 50
    
    var width: Float = 50
    
    var mime: String = "png"
    
}

class FakeArtwork: Artwork {
    var image: ArtworkImage = FakeArtworkImage()
    
    var id: String = "-1"
    
    var name: String = "Perfect"
    
    var info: Observable<ArtworkInfo> {
        return Observable.just(FakeArtworkInfo())
    }
}

class FakeMarketableArtwork: MarketableArtwork {
    
    var purchased: Observable<Void> {
        return purchaseSubject.asObservable()
    }
    
    var purchaseSubject = PublishSubject<Void>()
    
    func acquire() -> Observable<Acquisition> {
        return Observable.just(FakeAqcuisition())
    }
    
    func like() -> Observable<Void> {
        return Observable<Void>.never()
    }
    
    var image: ArtworkImage = FakeArtworkImage()
    
    var id: String = "-1"
    
    var name: String = "Perfect"
    
    var info: Observable<ArtworkInfo> {
        return Observable.just(FakeArtworkInfo())
    }
    
}

class FakeAqcuisition: Acquisition {
    var price: Float = 999.99
    
    var purchase_params: [String : Any] = ["":""]
    
    var purchasable: Purchasable = FakePurchasable()
    
    var seller: Artist = ArtistFromJSON()
    
    func purchase() -> Observable<Void> {
        return Observable.just({}())
    }
    
}

class FakePurchasable: Purchasable {
    var name: String = "Monalisa"
    
    var image: ObservableImage = FakeObservableImage()
}

protocol Artworks {
    func asObservable() ->  Observable<[Artwork]>
}


class FakeArtworks: Artworks {
    func asObservable() -> Observable<[Artwork]> {
        return Observable.just([FakeArtwork()])
    }
}

protocol MarketableArtworks {
    func asObservable() ->  Observable<[MarketableArtwork]>
}

class FakeMarketableArtworks: MarketableArtworks {
    func asObservable() -> Observable<[MarketableArtwork]> {
        return Observable.just([FakeMarketableArtwork()])
    }
}
