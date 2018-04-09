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
    
    func like() -> Observable<Void> {
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
    
    
    func like() -> Observable<Void> {
        return Observable.never()
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
        self.name = artwork.name
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
    typealias Response = ArtworksFromJSON
    
    var route: String = "artworks/owned"
    var method: Alamofire.HTTPMethod = .get
}
