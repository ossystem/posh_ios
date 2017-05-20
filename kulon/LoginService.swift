//
//  Auth.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 17/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper







class LoginApiService: ApiService {
    
    static let shared = LoginApiService()
    
    typealias Parameter = UserCredentials
    typealias Response = AuthResult
    
    var route: String = "auth"
    var method: HTTPMethod = .post

}

class LoginService {
    func login(with credentials: UserCredentials) -> Observable<Void> {
         return LoginApiService.shared.request(parameter: credentials)
            .flatMap { (result) -> Observable<Void> in
                TokenService().token = result.token
                return Observable<Void>.empty()
        }
    }
}



class UserCredentials: ParameterType {
    
    let password : String
    let email : String
    
    init(email: String, password: String) {
        self.password = password
        self.email = email
    }
    
    func toJSON() -> [String : Any]? {
        return
            ["password": password,
             "email": email]
    }

}

class AuthResult: ResponseType {
    var token: String = ""
    required init(map: Map) throws {
        token <- map["token"]
    }
}

