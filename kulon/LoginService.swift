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

    
    typealias Parameter = UserCredentials
    typealias Response = AuthResult
    
    var route: String = "login"
    var method: HTTPMethod = .post

}

class AuthApiService: ApiService {


    typealias Parameter = PhoneNumber
    typealias Response = AuthResult

    var route: String = "auth"
    var method: HTTPMethod = .post

}

class PhoneNumber: ParameterType, ResponseType {


    private var string: String

    init(with string: String) {
        self.string = string
    }

    required init(map: Map) throws {
        string = try map.value("phone")
    }

    func toJSON() -> [String: Any]? {
        return ["phone": string]
    }
}

class NoCredentilasError: LocalizedError {
    
    var localizedDescription: String  = "User credentials not provided"
    var errorDescription: String? {
        return localizedDescription
    }
}

class LoginService {
    
    let userCredentialsService = UserCredentialsService()
    let loginApiService = LoginApiService()
    let tokenService = TokenService()
    let authService = AuthApiService()

    func auth(with phoneNumber: PhoneNumber) -> Observable<Void> {
        return Observable.never()
        
    }
    
    func login(with credentials: UserCredentials) -> Observable<Void> {
         return loginApiService.request(parameter: credentials)
            .flatMap { (result) -> Observable<Void> in
                self.userCredentialsService.credentials = credentials
                self.tokenService.token = result.token
                self.userCredentialsService.isLoggedIn = true
                return Observable<Void>.empty()
        }
    }
    
    func loginWithStoredCredentials() -> Observable<Void> {
        guard let credentials = userCredentialsService.credentials else {
            return Observable.error(NoCredentilasError())
        }
        return loginApiService.request(parameter: credentials)
            .flatMap { (result) -> Observable<Void> in
                TokenService().token = result.token
                return Observable<Void>.empty()
            }.do( onError: { error in
                self.logout()
            })
    }
    
    func logout() {
        let authController = UIStoryboard.init(name: "Auth", bundle: nil).instantiateInitialViewController()
        userCredentialsService.isLoggedIn = false
        UIApplication.shared.windows.first?.replaceRootViewControllerWith(authController!)
    }
}



class UserCredentials: NSObject, ParameterType {
    
    let password : String
    let email : String
    
    init(email: String, password: String) {
        self.password = password
        self.email = email
    }
    init(from dictionary: [String: Any]) {
        password = dictionary["password"] as! String
        email = dictionary["email"] as! String 
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

