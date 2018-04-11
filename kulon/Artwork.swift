//
//  Artwork.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 21/03/2018.
//  Copyright © 2018 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import Alamofire

protocol Artwork: IdiableObject, NamedObject {
    var info: Observable<ArtworkInfo> { get }
    var image: ArtworkImage { get }
    var isPurchased: Bool { get }
    var isLiked: Bool { get }
    func like() -> Observable<Bool>
}



protocol Purchasable {
    var purchased: Observable<Void> {get}
}

protocol ArtworkInfo: NamedObject, IdiableObject {
    var minPrice: Int { get }
    var acquisitionParams: DictionaryParams { get }
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

class ArtworkImageFromJSON: ArtworkImage, ResponseType {
    
    var link: String
    var height: Float
    var width: Float
    var mime: String
    
    required init(map: Map) throws {
        link = try map.value("link")
        height = try map.value("height")
        width = try map.value("width")
        mime = try map.value("mime")
    }
    
    
}

protocol Artist: IdiableObject, NamedObject {
    var avatar: ObservableImage { get }
}

protocol ArtworkFormat: IdiableObject {
    var deviceCode: String {get}
}

class ArtworkInfoFromJSON: ArtworkInfo, ResponseType {
    
    var id: String
    var minPrice: Int
    var acquisitionParams: DictionaryParams
    var image: ArtworkImage
    var artist: Artist
    var formats: [ArtworkFormat] = []
    var name: String
    
    required init(map: Map) throws {
        id = try map.value("artwork.id")
        name = try map.value("artwork.name")
        image = try map.value("artwork.image") as ArtworkImageFromJSON
        minPrice = try map.value("artwork.min_price")
        acquisitionParams = try DictionaryParams(dict: map.value("artwork.acquisition_params"))
        artist = try map.value("artwork.artist") as ArtistFromJSON
        
    }
}


class ObservableArtworkInfo {
    
    func asObservable() -> Observable<ArtworkInfoFromJSON> {
        return artworkInfoApiService.request(parameter: ParameterNone())
    }
    private var artworkInfoApiService : ArtworkInfoApiService
    init(artwork: Artwork) {
        self.artworkInfoApiService = ArtworkInfoApiService(artwork: artwork)
    }
    
}


class IdParameter: ParameterType {
    private var id: String
    
    init(id: String) {
        self.id = id
    }
    
    init(object: IdiableObject) {
        self.id = object.id
    }
    
    func toJSON() -> [String : Any]? {
        return ["id": id]
    }
}
class ArtworkInfoApiService: ApiService {
    typealias Response = ArtworkInfoFromJSON
    typealias Parameter = ParameterNone
    
    var route: String
    var method: HTTPMethod = .get
    
    init(artwork: Artwork) {
        route = "artworks/\(artwork.id)"
    }
    
}

class FakeArtworkInfo: ArtworkInfo {
    var id: String = "-1"
    
    var name: String = "Jaconda"
    
    var minPrice: Int = 29
    
    var acquisitionParams = DictionaryParams(dict: [
        "id": "8a5674eb-b26d-484a-8c87-841cb0492694",
        "type": "artwork"
    ])
    
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
    var isLiked: Bool = true
    
    func like() -> Observable<Bool> {
        return Observable.never()
    }
    
    var image: ArtworkImage = FakeArtworkImage()
    
    var id: String = "-1"
    
    var name: String = "Perfect"
    
    var info: Observable<ArtworkInfo> {
        return Observable.just(FakeArtworkInfo())
    }
    
    var purchased: Observable<Void> {
        return Observable.never()
    }
    var isPurchased: Bool = false
}

class ArtworkFromJSON: Artwork, ResponseType {
    var isLiked: Bool
    
    var info: Observable<ArtworkInfo> {
        return ObservableArtworkInfo(artwork: self).asObservable().map { $0 as ArtworkInfo }
    }
    
    var image: ArtworkImage
    
    var id: String
    
    var name: String
    
    var isPurchased: Bool

    private lazy var likeService = LikeApiService(artwork: self)
    private lazy var dislikeService = DisikeApiService(artwork: self)
    
    func like() -> Observable<Bool> {
        if isLiked {
            return dislikeService.request(parameter: ParameterNone()).map{ _ in false}
        } else {
            return likeService.request(parameter: ParameterNone()).map {_ in true }
        }
    }
    
    required init(map: Map) throws {
        do {
            id = try map.value("id")
            name = try map.value("name")
            image = try map.value("image") as ArtworkImageFromJSON
            isPurchased = try map.value("is_purchased")
            isLiked = try map.value("is_favorite")
        }
        catch { //FIXME: to handle purchases
            id = try map.value("artwork.id")
            name = try map.value("artwork.name")
            image = try map.value("artwork.image") as ArtworkImageFromJSON
            isPurchased = true
            isLiked = try map.value("is_favorite")
        }
    }
}

class LikeApiService: ApiService {
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
    
    var route: String
    var method: HTTPMethod = .post
    
    init(artwork: Artwork) {
        route = "artworks/favorites/\(artwork.id)"
    }
}

class DisikeApiService: ApiService {
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
    
    var route: String
    var method: HTTPMethod = .delete
    
    init(artwork: Artwork) {
        route = "artworks/favorites/\(artwork.id)"
    }
}



protocol Artworks {
    func asObservable() ->  Observable<[Artwork]>
}


class FakeArtworks: Artworks {
    func asObservable() -> Observable<[Artwork]> {
        return Observable.just([FakeArtwork()])
    }
}

protocol Selectable {
    var viewControllerToPresentt: UIViewController { get }
}

class ArtworksFromJSON: ResponseType {
    let artworks: [ArtworkFromJSON]
    
    required init(map: Map) throws {
        do  {
            artworks = try map.value("artworks") as [ArtworkFromJSON]
        }
        catch { //FIXME: to handle purchases
            artworks = try map.value("purchases") as [ArtworkFromJSON]
        }
    }
}
