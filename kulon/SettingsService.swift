//
//  SettingsService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 22/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import Alamofire

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

class FAQSettingsService: SettingsService {
    var method: HTTPMethod = .get
    var route: String = "faq"
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}

class AdressesSettingsService: SettingsService {
    var method: HTTPMethod = .get
    var route: String = "adresses"
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
}
