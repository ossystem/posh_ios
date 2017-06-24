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
        self.route = "market/\(id)/fav"
    }
    
    var method: HTTPMethod = .post
    var route: String
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}

class DislikePoshikApiService: ApiService {
    
    init(with id: Int) {
        self.route = "favorites/\(id)"
    }
    
    var method: HTTPMethod = .delete
    var route: String
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}

class BuyPoshikApiService: ApiService {
    
    init(with id: Int) {
        self.route = "market/\(id)"
    }
    
    var method: HTTPMethod = .post
    var route: String
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}

class DeletePoshikApiService: ApiService {
    
    var method: HTTPMethod = .delete
    var route: String

    init(with id: Int) {
        self.route = "poshiks/my/\(id)"
    }
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}

class PoshikService {
    
    let likeApiService: LikePoshikApiService
    let dislikeApiService: DislikePoshikApiService
    let buyApiService: BuyPoshikApiService
    let deleteApiService: DeletePoshikApiService
    
    let poshik: Poshik
    
    init(with poshik: Poshik) {
        let id = poshik.id
        likeApiService = LikePoshikApiService(with: id)
        dislikeApiService = DislikePoshikApiService(with: id)
        buyApiService = BuyPoshikApiService(with: id)
        deleteApiService = DeletePoshikApiService(with: id)
        self.poshik = poshik
    }
    
    
    func like() -> Observable<ResponseNone> {
        if !poshik.isLiked {
            return likeApiService.request(parameter: ParameterNone())
        } else {
            return dislikeApiService.request(parameter: ParameterNone())
        }
    }

    func buy() -> Observable<ResponseNone> {
        return buyApiService.request(parameter: ParameterNone())
    }
    
    //TODO: move somewhere, diverse market and uploaded opshiks
    func delete() -> Observable<ResponseNone> {
        return deleteApiService.request(parameter: ParameterNone())
    }
}
