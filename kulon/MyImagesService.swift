//
//  MyImagesService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 21/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RxSwift

class MyPoshiksApiService : ApiService {
    
    var method: HTTPMethod = .get
    var route: String = "poshiks/my"
    
    typealias Response = MyPoshiksJSON
    typealias Parameter = ParameterNone
    
}

class PurchasedPoshiksApiService : ApiService {
    
    var method: HTTPMethod = .get
    var route: String = "poshiks/purchase"
    
    typealias Response = PurchasedPoshiksJSON
    typealias Parameter = ParameterNone
    
}

class AddPoshikApiService : ApiService {
 
    var method: HTTPMethod = .post
    var route: String = "poshiks/my"
    
    typealias Response = ResponseNone
    typealias Parameter = PoshikFromRedactor
    
}



class MyPoshiksService {
    
    let myPoshiksService = MyPoshiksApiService()
    let purchasedPoshiksService = PurchasedPoshiksApiService()
    let addService = AddPoshikApiService()
    
    func getMyPoshiks() -> Observable<MyPoshiksJSON> {
        return myPoshiksService.request(parameter: ParameterNone())
    }
    
    func getPurchasedPoshiks() -> Observable<PurchasedPoshiksJSON> {
        return purchasedPoshiksService.request(parameter: ParameterNone())
    }
    
    func addPoshikFromRedactor(_ poshik: PoshikFromRedactor) -> Observable<ResponseNone> {
        return addService.upload(parameter: poshik)
    }
}

class PoshikFromRedactor : UploadableParameter {
    
    var image: UIImage
    
    var content: Data? {
        return UIImageJPEGRepresentation(image, 1)
    }
    var contentName: String = "poshik"
    
    init(with image: UIImage) {
        self.image = image
    }
    
    func toJSON() -> [String : Any]? {
        return nil
    }
    
}

class MyPoshiksJSON : ResponseType {
    
    var poshiks: [MyPoshikUploaded] = []
    
    subscript(index: Int) -> Poshik {
        return poshiks[index]
    }
    
    required init(map: Map) throws {
        poshiks = try map.value("myPoshiks")
    }
}

class PurchasedPoshiksJSON: ResponseType {
    var poshiks: [MyPoshikFromMarket] = []
    
    subscript(index: Int) -> Poshik {
        return poshiks[index]
    }
    
    required init(map: Map) throws {
        poshiks = try map.value("purchases")
    }
}

class PurchasedPoshiks : ObservableType {
    
    private let service = MyPoshiksService()
    
    typealias E  = [Poshik]
    
    func subscribe<O:ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return service.getPurchasedPoshiks()
            .asObservable()
            .map { $0.poshiks }
            .subscribe(observer)
    }
}

class MyPsohiks : ObservableType {
    
    private let service = MyPoshiksService()
    
    typealias E  = [Poshik]
    
    func subscribe<O:ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return service.getMyPoshiks()
            .asObservable()
            .map { $0.poshiks }
            .subscribe(observer)
    }
}
