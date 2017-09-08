//
//  TockenService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class TokenService {
    
    private let key = "TokenKey"
    let service = TokenApiService()
    
    var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
        get {
            return UserDefaults.standard.string(forKey: key)
        }
    }
    
    func refresh() -> Observable<Void> {
        guard  let token = token else {
            return Observable.error(UnauthorisedError())
        }
        return service.request(parameter: TokenParameter(token))
            .do(onNext: { [unowned self] in
                self.token = $0.token
                }, onError: { _ in
                    LoginService().logout()
            })
            .map { _ in  }
    }
}

class TokenApiService: ApiService {
    
    typealias Parameter = TokenParameter
    typealias Response = AuthResult
    
    var method: HTTPMethod = .post
    var route: String = "new-token"
    
    
}

class TokenParameter: ParameterType {
    
    let token: String
    
    init(_ token: String) {
        self.token = token
    }
    
    func toJSON() -> [String : Any]? {
        return ["token" : token]
    }
}
