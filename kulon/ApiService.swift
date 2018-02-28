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

protocol UploadableParameter : ParameterType {
    var content: Data? { get }
    var contentName: String { get }
}

class ParameterNone : ParameterType {
    func toJSON() -> [String : Any]? {
        return nil
    }
}

protocol ResponseType: ImmutableMappable {
    
}

class ResponseNone : ResponseType {
    
    required init(map: Map) throws {
        
    }
}

protocol ApiService : class {
    
    associatedtype Parameter : ParameterType
    associatedtype Response : ResponseType
    
    var method: HTTPMethod { get }
    var baseRoute: String { get }
    var route: String { get }
    var headers: [String : String] { get }
    
    func request(parameter: Parameter) -> Observable<Response>
    func upload(parameter: UploadableParameter) -> Observable<Response>
    
}

extension SessionManager {
    static var kulonManager: SessionManager {
        let config = URLSessionConfiguration()
        config.httpMaximumConnectionsPerHost = 1
        return SessionManager(configuration: config)
    }
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
        let tokenService = TokenService()
        let loginService = LoginService()
        return Observable.create { observer in
            Alamofire.request(URL(string: self.baseRoute + self.route)!,
                              method: self.method,
                              parameters: parameter.toJSON(),
                              encoding: URLEncoding.default,
                              headers: self.headers)
                .responseObject(keyPath: "data")
                {  (response: DataResponse<Response>)  in
                    switch response.result {
                    case .success(let value):
                        self.updateAuthorizationToken(response: response)
                        observer.on(.next(value))
                        observer.onCompleted()
                    case .failure(let error):
                        guard let innerResponse = response.response
                            else {
                                observer.on(.error(error))
                                break
                        }
                        switch innerResponse.statusCode {
                        case 401:
                            
                            //TODO: try to rewrite with retryWhen
                            
                            tokenService.refresh().subscribe(onNext: { _ in
                                self.request(parameter: parameter).subscribe(
                                    onNext: { value in
                                    observer.onNext(value)
                                },  onError: {
                                    observer.onError($0)
                                },
                                    onCompleted: {
                                    observer.onCompleted()
                                })
                            }, onError: { error in
                                    loginService.loginWithStoredCredentials().subscribe(onNext: {
                                        self.request(parameter: parameter).subscribe(onNext: { value in
                                            observer.onNext(value)
                                        }, onError: {
                                            observer.onError($0)
                                        }, onCompleted: {
                                            observer.onCompleted()
                                        })
                                })
                            })
                            
                        case 300:
                            observer.on(.error(UserNotExistError()))
                        default:
                            if let data = response.data {
                                observer.on(.error(self.getError(from: data)))
                            } else {
                                observer.on(.error(error))
                            }
                        }
                    }
            }
            return Disposables.create()
            }
//            .retryWhen({ (errorObservable : Observable<Error>) -> Observable<Void> in
//            return errorObservable.flatMap { (error) -> Observable<Void> in
//                if error is UnauthorisedError {
//                    return LoginService().loginWithStoredCredentials()
//                }
//                throw error
//            }
//        })
        
    }
    
    func upload(parameter: UploadableParameter) -> Observable<Response> {
    
        return Observable.create { observer in
            guard let request = try? URLRequest(url: URL(string: self.baseRoute + self.route)!, method: self.method, headers: self.headers )
                else {
                    observer.onError( (ResponseError(message: "Can't create request")))
                    return Disposables.create()
            }
            Alamofire.upload(multipartFormData: { data in
                guard let content = parameter.content else {
                    observer.onError(ResponseError(message: "Can't attach file"))
                    return
                }
                data.append(content, withName: "poshik", fileName: "poshik", mimeType: "image/jpeg")
                if let parameters = parameter.toJSON() {
                    for (key, value) in parameters {
                        data.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
            }, with: request  ) { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseObject(keyPath: "data")
                        { [unowned self] (response: DataResponse<Response>)  in
                            switch response.result {
                            case .success(let value):
                                self.updateAuthorizationToken(response: response)
                                observer.on(.next(value))
                                observer.onCompleted()
                            case .failure(let error):
                                guard let innerResponse = response.response
                                    else {
                                        observer.on(.error(error))
                                        break
                                }
                                switch innerResponse.statusCode {
                                case 401:
                                    observer.on(.error(UnauthorisedError()))
                                case 300:
                                    observer.on(.error(UserNotExistError()))
                                default:
                                    if let data = response.data {
                                        print(data)
                                        observer.on(.error(self.getError(from: data)))
                                    } else {
                                        observer.on(.error(error))
                                    }
                                }
                            }
                    }
                case .failure:
                    break
                }
            }
            return Disposables.create()
            }.retryWhen({ (errorObservable : Observable<Error>) -> Observable<Void> in
            return errorObservable.flatMap { (error) -> Observable<Void> in
                if error is UnauthorisedError {
                    return LoginService().loginWithStoredCredentials()
                }
                throw error
            }
        })
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


class UnauthorisedError : ResponseError { }

class UserNotExistError : ResponseError { }

class ResponseError: LocalizedError, Mappable {
    
    var message: String = "Низвестная ошибка"
    var description: [String]?
    var errorDescription: String? {
        return description?.joined(separator: " ") ?? message
    }
    
    init() {
        
    }
    
    init(message: String) {
        self.message = message
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
