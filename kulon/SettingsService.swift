//
//  SettingsService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 22/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

protocol SettingsService : ApiService {
    
    func getRequest() -> URLRequest
}

extension SettingsService {
    
    func getRequest() -> URLRequest {
        return URLRequest(url: URL(string: baseRoute + route)!)
    }
}

class ContactsSettingsService : SettingsService {
    
    var method: HTTPMethod = .get
    var route: String = "contacts"
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone

}

class FAQSettingsApiService: ApiService {
    
    static var shared = FAQSettingsApiService()
    
    var method: HTTPMethod = .get
    var route: String = "faq"
    
    typealias Parameter = ParameterNone
    typealias Response = FAQuestions
}

class FAQSettingsService {
    
    var apiService = FAQSettingsApiService.shared
    
    func getQuestions() -> Observable<FAQuestions> {
        return apiService.request(parameter: ParameterNone())
    }
    
}

class AdressesSettingsService: SettingsService {
    var method: HTTPMethod = .get
    var route: String = "adresses"
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}
