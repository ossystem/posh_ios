//
//  OwnedArtwork.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 03/04/2018.
//  Copyright © 2018 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import ObjectMapper

protocol OwnedArtwork: Artwork, Purchasable, Selectable {
    func setToDevice() -> Observable<Void> //FIXME: TEMP
}

extension OwnedArtwork {
    var purchased: Observable<Void> {
        return Observable.just()
    }
    
    var viewControllerToPresentt: UIViewController {
        return OwnedArtworkController(ownedArtwork: self)
    }
}

class FakeOwnedArtwork: OwnedArtwork {
    var isLiked: Bool = false
    
    func like() -> Observable<Bool> {
        return Observable.never()
    }
    
    func setToDevice() -> Observable<Void> {
        return Observable.just()
    }
    
    var info: Observable<ArtworkInfo> {
        return Observable.just(FakeArtworkInfo())
    }
    
    var image: ArtworkImage = FakeArtworkImage()
    
    var id: String = "-1"
    
    var name: String = "Jaconda"
        var isPurchased: Bool = false
}

protocol OwnedArtworks {
    func asObservable() -> Observable<[OwnedArtwork]>
}

class FakeOwnedArtworks : OwnedArtworks {
    func asObservable() -> Observable<[OwnedArtwork]> {
        return Observable.just([FakeOwnedArtwork()])
    }
}

class OwnedArtworkFromArtwork: OwnedArtwork, UploadablePoshik {
    var isLiked: Bool {
        return origin.isLiked
    }
    
    
    func like() -> Observable<Bool> {
        return origin.like()
    }
    
    var imageForUpload: Observable<Uploadable> {
        
        return info.asObservable()
            .flatMap { UploadableImage(artworkInfo: $0) }
    }
    
    var id: String
    
    var name: String
    
    var bleService = BLEService.shared
    
    func setToDevice() -> Observable<Void> {
        return bleService.set(self)
    }
    
    var info: Observable<ArtworkInfo> {
        return origin.info
    }
    
    var image: ArtworkImage {
        return origin.image
    }
    
    var purchased: Observable<Void> {
        return Observable.just()
    }
    
    var isPurchased: Bool {
        return origin.isPurchased
    }
    
    private var origin: Artwork
    
    init(artwork: Artwork) {
        self.origin = artwork
        self.name = "\(artwork.name).mjpeg"
        self.id = artwork.id
    }
}

class OwnedArtworksFromAPI: OwnedArtworks {
    func asObservable() -> Observable<[OwnedArtwork]> {
        return OwnedArtworksApiService().request(parameter: ParameterNone()).map {
            $0.artworks.map { OwnedArtworkFromArtwork(artwork: $0) }
        }
    }
}



class OwnedArtworksApiService: ApiService {
    
    typealias Parameter = ParameterNone
    typealias Response = OwnedArtworksFromJSON
    
    var route: String = "artworks/owned"
    var method: Alamofire.HTTPMethod = .get
}



class OwnedArtworksFromJSON: ResponseType {
    let artworks: [OwnedArtworkFromJSON]
    
    required init(map: Map) throws {
        artworks = try map.value("purchases") as [OwnedArtworkFromJSON]
    }
}

class OwnedArtworkFromJSON: Artwork, ResponseType {
    var isLiked: Bool
    
    var info: Observable<ArtworkInfo> {
        return ObservableOwnedArtworkInfo(artwork: self).asObservable().map { $0 as ArtworkInfo }
    }
    
    var image: ArtworkImage
    
    var id: String
    
    var name: String
    
    var isPurchased: Bool
    
    private lazy var likeService = LikeApiService(artwork: self)
    private lazy var dislikeService = DisikeApiService(artwork: self)
    
    func like() -> Observable<Bool> {
        if isLiked {
            return dislikeService.request(parameter: ParameterNone())
                .map{ _ in
                    self.isLiked = false
                    return false
            }
        } else {
            return likeService.request(parameter: ParameterNone())
                .map {_ in
                    self.isLiked = true
                    return true
            }
        }
    }
    
    required init(map: Map) throws {
        
          //FIXME: to handle purchases
            id = try map.value("artwork.id")
            name = try map.value("artwork.name")
            image = try map.value("artwork.image") as ArtworkImageFromJSON
            isPurchased = true
            isLiked = try map.value("artwork.is_favorite")
    }
}

class ObservableOwnedArtworkInfo {
    
    func asObservable() -> Observable<ArtworkInfoFromJSON> {
        return artworkInfoApiService.request(parameter: ParameterNone())
    }
    private var artworkInfoApiService : OwnedArtworkInfoApiService
    init(artwork: Artwork) {
        self.artworkInfoApiService = OwnedArtworkInfoApiService(artwork: artwork)
    }
    
}


class OwnedArtworkInfoApiService: ApiService {
    typealias Response = ArtworkInfoFromJSON
    typealias Parameter = ParameterNone
    
    var route: String
    var method: HTTPMethod = .get
    
    init(artwork: Artwork) {
        route = "artworks/owned/\(artwork.id)"
    }
    
}
