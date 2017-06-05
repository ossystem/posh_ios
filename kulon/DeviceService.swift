//
//  DeviceService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 02/06/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class AddMyDeviceApiService: ApiService {
    
    var method: HTTPMethod = .post
    var route: String = "device"
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
    
}

class DeleteMyDeviceApiService: ApiService {
    
    var method: HTTPMethod = .delete
    var route: String = "device"
    
    typealias Parameter = ParameterNone
    typealias Response = ResponseNone
    
}

class MyDeviceService {
    
    let addService = AddMyDeviceApiService()
    let deleteService = DeleteMyDeviceApiService()
    
    func addDevice() -> Observable<ResponseNone> {
        return addService.request(parameter: ParameterNone())
    }
    
    func deleteDevice() -> Observable<ResponseNone> {
        return deleteService.request(parameter: ParameterNone())
    }
}
