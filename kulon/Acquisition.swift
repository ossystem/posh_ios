//
//  Acquisition.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 06/04/2018.
//  Copyright © 2018 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import Alamofire


protocol Acquisition {
    
    var price: Float { get }
    var purchase_params: [String: Any] { get }
    var purchasable: Purchase { get }
    var seller: Artist { get } //FIXME: TEMP
    
    func purchase() -> ObservablePurchaseOperation
    
}

class FakeAqcuisition: Acquisition {
    var price: Float = 999.99
    
    var purchase_params: [String : Any] = ["":""]
    
    var purchasable: Purchase = FakePurchase()
    
    var seller: Artist = ArtistFromJSON()
    
    func purchase() -> ObservablePurchaseOperation {
        return ObservablePurchaseOperation(acquisition: self)
    }
    
}

protocol ObservableAcquisition {
    func asObservable() -> Observable<Acquisition>
}

class ObservableAcquisitionFromAPI: ObservableAcquisition {
    
    private var service = AcquisitionApiService()
    private var artworkInfo: ArtworkInfo
    
    init(artworkInfo: ArtworkInfo) {
        self.artworkInfo = artworkInfo
    }
    
    func asObservable() -> Observable<Acquisition> {
        return service.request(parameter: artworkInfo.acquisitionParams).map { $0 as Acquisition }
    }
}

class AcquisitionFromJSON: Acquisition, ResponseType {
    var price: Float
    
    var purchase_params: [String : Any]
    
    var purchasable: Purchase
    
    var seller: Artist
    
    func purchase() -> ObservablePurchaseOperation {
        return ObservablePurchaseOperation(acquisition: self)
    }
    
    required init(map: Map) throws {
        seller = try map.value("acquisition.seller") as ArtistFromJSON
        purchase_params = try map.value("acquisition.purchase_params")
        price = try map.value("acquisition.price")
        purchasable = try map.value("acquisition.purchasable") as PurchaseFromJSON
    }
}

class ObservablePurchaseOperation: ObservableType {
    
    private var acquisition: Acquisition
    private var service = PurchaseAPIService()
    typealias E = Void
    
    init(acquisition: Acquisition) {
        self.acquisition = acquisition
    }
    
    func subscribe<O:ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return service.request(parameter: DictionaryParams(dict: acquisition.purchase_params))
            .map{ _ in }
            .subscribe(observer)        
    }
    
}



class PurchaseAPIService: ApiService {
    typealias Parameter = DictionaryParams
    typealias Response = ResponseNone
    
    var route: String = "purchase"
    var method: HTTPMethod = .post
}

class DictionaryParams: ParameterType {
    private var dict: [String: Any]
    
    init(dict: [String: Any]) {
        self.dict = dict
    }
    
    func toJSON() -> [String : Any]? {
        return dict
    }
}

class AcquisitionApiService: ApiService {
    typealias Parameter = DictionaryParams
    
    typealias Response = AcquisitionFromJSON
    
    var route: String = "acquisition"
    var method: HTTPMethod = .get
}
