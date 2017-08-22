//
//  SocialService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 11/07/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import ObjectMapper
import RxSwift

class SocialApiService: ApiService {
    var method: HTTPMethod = .get
    var route: String = "socialite"
    typealias Parameter = SocialLoginParameter
    typealias Response = SocialLoginLink
}

enum SocialAuthProvider: String {
    case vkontakte = "vkontakte", facebook = "facebook"
}

class SocialLoginParameter : ParameterType {

    private var type: SocialAuthProvider
    
    init(with type: SocialAuthProvider) {
        self.type = type
    }
    
    func toJSON() -> [String : Any]? {
        return ["provider": type.rawValue]
    }
}

class SocialLoginLink: ResponseType {
    
    var loginLink: String = ""
    
    required init(map: Map) throws {
        loginLink <- map["link"]
    }
}

class SocialService {
    
    let apiService = SocialApiService()
    
    func requestLogin(with socialNetworktype: SocialAuthProvider) -> Observable<SocialLoginLink> {
        return apiService.request(parameter: SocialLoginParameter(with: socialNetworktype))
        
    }
    
}


