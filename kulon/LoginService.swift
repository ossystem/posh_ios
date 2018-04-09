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
import SwiftyJSON

class LoginApiService: ApiService {

    
    typealias Parameter = UserCredentials
    typealias Response = AuthResult
    
    var route: String = "login"
    var method: HTTPMethod = .post

}

class AuthApiService: ApiService {


    typealias Parameter = UserPhoneNumber
    typealias Response = UserPhoneNumber

    var route: String = "auth"
    var method: HTTPMethod = .post

}

protocol StringConvertable {
    func toString() -> String
}

class UserPhoneNumber: ParameterType, ResponseType, StringConvertable {


    private var string: String

    init(with string: String) {
        if string.first != "+" { self.string = "+" + string }
        else { self.string = string }
    }

    required init(map: Map) throws {
        string = try map.value("phone")
    }

    func toJSON() -> [String: Any]? {
        return ["phone": string]
    }
    
    func toString() -> String {
        return string
    }
}

class NoCredentilasError: LocalizedError {
    
    var localizedDescription: String  = "User credentials not provided"
    var errorDescription: String? {
        return localizedDescription
    }
}

class PoshNetwork: Network {
    
    var network: Network
    init() {
        network = SimpleNetwork(session: URLSession(configuration: URLSessionConfiguration.default),
                                    url: "https://posh.jwma.ru/api/v1/",
                                    headers: ["Accept": "application/json",
                                              "Content-Type":"application/x-www-form-urlencoded"])
    }
    
    func call(method: String, params: ParameterType) throws -> Data {
        return try network.call(method: method, params: params)
    }
    
}

class LoginService {
    
    let userCredentialsService = UserCredentialsService()
    let loginApiService = LoginApiService()
    let tokenService = TokenService()
    let authService = AuthApiService()
    
    let poshNetwork: Network
    
    init(){
        poshNetwork = PoshNetwork()
    }

    func auth(with phoneNumber: UserPhoneNumber) -> Observable<UserPhoneNumber> {
        
        return authService.request(parameter: phoneNumber)
        
        
//        return Observable.create{ observer in
//            do {
//                observer.on(.next(try JSON(data: self.poshNetwork.call(method: "auth", params: phoneNumber))["data.phone"].string()))
//                observer.on(.completed)
//            } catch let err {
//                observer.on(.error(err))
//            }
//            return Disposables.create()
//        }
        
    }
    
    func login(with credentials: UserCredentials) -> Observable<Void> {
         return loginApiService.request(parameter: credentials)
            .flatMap { (result) -> Observable<Void> in
                self.userCredentialsService.credentials = credentials
                self.tokenService.token = result.token
                self.userCredentialsService.isLoggedIn = true
                return Observable<Void>.just()
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
    let phone : String
    
    init(phone: UserPhoneNumber, password: String) {
        self.password = password
        self.phone = phone.toString()
    }
    init(from dictionary: [String: Any]) {
        password = dictionary["password"] as! String
        phone = dictionary["code"] as! String
    }
    
    func toJSON() -> [String : Any]? {
        return
            ["code": password,
             "phone": phone]
    }

}

class AuthResult: ResponseType {
    var token: String = ""
    required init(map: Map) throws {
        token <- map["token"]
    }
}

