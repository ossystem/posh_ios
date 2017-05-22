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
    static let shared = MyPoshiksApiService()
    
    var method: HTTPMethod = .get
    var route: String = "my_poshiks"
    
    typealias Response = MyPoshiks
    typealias Parameter = ParameterNone
}

class MyPoshiksService {
    
    let apiService = MyPoshiksApiService.shared
    
    func getPoshiks() -> Observable<MyPoshiks> {
        return apiService.request(parameter: ParameterNone())
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
