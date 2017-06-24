//
//  RegistrationService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import RxSwift

class RegistraionApiService: ApiService {
    static var shared = RegistraionApiService()
    
    var route: String = "registration"
    var method: HTTPMethod = .post
    
    typealias Parameter = UserCredentials
    typealias Response = AuthResult
    
}

class RegistrationService {
    
    private let apiService = RegistraionApiService.shared
    
    func register(with parameter: UserCredentials) -> Observable<Void>{
        return apiService.request(parameter: parameter)
            .flatMap { (result) -> Observable<Void> in
                TokenService().token = result.token
                UserCredentialsService().credentials = parameter
                return Observable<Void>.empty()
        }
    }
}

