//
//  ApiService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

protocol ParameterType {
    func toJSON() -> [String : Any]?
}


protocol ResponseType: ImmutableMappable {
    
}

protocol ApiService : class {
    
    associatedtype Parameter : ParameterType
    associatedtype Response : ResponseType
    
    var method: HTTPMethod { get }
    var baseRoute: String { get }
    var route: String { get }
    var headers: [String : String] { get }
    
    func request(parameter: Parameter) -> Observable<Response>
}

extension ApiService {
    
    var baseRoute: String {
        return "http://kulon.jwma.ru/api/v1/"
    }
    var headers: [String : String] {
        if let token = TokenService().token {
            return ["Authorization" : "Bearer \(token)"]
        } else {
            return [:]
        }
    }
    
    func request(parameter: Parameter) -> Observable<Response> {
        return Observable.create{ observer in
            Alamofire.request(URL(string: self.baseRoute + self.route)!,
                              method: self.method,
                              parameters: parameter.toJSON(),
                              encoding: URLEncoding.default,
                              headers: self.headers)
                .responseObject(keyPath: "data")
                { [unowned self] (response: DataResponse<Response>)  in
                    switch response.result {
                    case .success(let value):
                        self.updateAuthorizationToken(response: response)
                        observer.on(.next(value))
                        observer.onCompleted()
                    case .failure(let error):
                        if let data = response.data {
                            observer.on(.error(self.getError(from: data)))
                        } else {
                            observer.on(.error(error))
                        }
                    }
            }
            return Disposables.create()
        }
    }
    
    private func updateAuthorizationToken(response: DataResponse<Response>) {
        if let token = response.response?.allHeaderFields["Authorization"] as? String {
            TokenService().token = token
        }
    }
    
    private func getError(from data: Data) -> Error {
        let errorArray = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any])
        return ResponseError(map: Map(mappingType: MappingType.fromJSON, JSON: errorArray ?? [:]))
    }
    
}

class ResponseError: LocalizedError, Mappable {
    
    var message: String = "Низвестная ошибка"
    var description: [String]?
    var errorDescription: String? {
        return description?.joined(separator: " ") ?? message
    }
    
    required init(map: Map) {
        message <- map["message"]
        description <- map["data"]
    }
    
    func mapping(map: Map) {
        message <- map["message"]
        description <- map["data"]
    }
    
}
