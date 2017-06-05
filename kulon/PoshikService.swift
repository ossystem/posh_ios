//
//  PoshikService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 20/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import ObjectMapper



class LikePoshikApiService: ApiService {
    
    init(with id: Int) {
        self.route = "market/\(id)/like"
    }
    
    var method: HTTPMethod = .post
    var route: String
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}

class DislikePoshikApiService: ApiService {
    
    init(with id: Int) {
        self.route = "market/\(id)/like"
    }
    
    var method: HTTPMethod = .delete
    var route: String
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}

class BuyPoshikApiService: ApiService {
    
    init(with id: Int) {
        self.route = "market/\(id)/buy"
    }
    
    var method: HTTPMethod = .post
    var route: String
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}

class PoshikService {
    
    let likeApiService: LikePoshikApiService
    let dislikeApiService: DislikePoshikApiService
    let buyApiService: BuyPoshikApiService
    
    init(with poshik: Poshik) {
        let id = poshik.id
        likeApiService = LikePoshikApiService(with: id)
        dislikeApiService = DislikePoshikApiService(with: id)
        buyApiService = BuyPoshikApiService(with: id)
    }
    
    func like() -> Observable<ResponseNone> {
        return likeApiService.request(parameter: ParameterNone())
    }
    
    func dislike() -> Observable<ResponseNone> {
        return dislikeApiService.request(parameter: ParameterNone())
    }

    func buy() -> Observable<ResponseNone> {
        return buyApiService.request(parameter: ParameterNone())
    }
}
