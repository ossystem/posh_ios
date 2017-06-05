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
    var route: String = "my_poshiks"
    
    typealias Response = MyPoshiks
    typealias Parameter = ParameterNone
    
}

class addPoshikApiService : ApiService {
 
    var method: HTTPMethod = .post
    var route: String = "my_poshiks"
    
    typealias Response = ResponseNone
    typealias Parameter = PoshikFromRedactor
    
}

class MyPoshiksService {
    
    let poshiksService = MyPoshiksApiService()
    let addService = addPoshikApiService()
    
    func getPoshiks() -> Observable<MyPoshiks> {
        return poshiksService.request(parameter: ParameterNone())
    }
    
    func addPoshikFromRedactor(_ poshik: PoshikFromRedactor) -> Observable<ResponseNone> {
        return addService.upload(parameter: poshik)
    }
}

class PoshikFromRedactor : UploadableParameter {
    
    var image: UIImage
    
    var content: Data? {
        return UIImagePNGRepresentation(image)
    }
    var contentName: String = "poshik"
    
    init(with image: UIImage) {
        self.image = image
    }
    
    //TODO: implemet
    func toJSON() -> [String : Any]? {
//        assertionFailure(" Poshik from redactor not implemented")
        return nil
    }
    
    
}

class MyPoshiks : ResponseType {
    
    var poshiks: [Poshik] = []
    
    subscript(index: Int) -> Poshik {
        return poshiks[index]
    }
    
    required init(map: Map) throws {
        poshiks = try map.value("poshiks")
    }
}
