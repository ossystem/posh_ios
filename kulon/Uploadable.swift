//
//  Uploadable.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 15/08/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol Uploadable {
    var data: Data { get }
}

enum BLEControlCommand : Uploadable {
    
    case openImage(String)
    case createImage(String)
    case closeWriting
    
    var data: Data {
        switch self {
        case .closeWriting:
            return "2".data(using: .utf8)!
        case let .openImage(name):
            return "4\(name).jpg#".data(using: .utf8)!
        case let .createImage(name):
            return "0\(name).jpg#".data(using: .utf8)!
        }
    }
    
}

struct UploadableFromData: Uploadable {
    var data: Data
}

protocol ObservableUploadable {
    func asObservable() -> Observable<Uploadable>
}


protocol ObservableImage {
    func asObservable() -> Observable<UIImage>
}

class UploadableImage : ObservableUploadable, ObservableType {
    
    let disposeBag = DisposeBag()
    var request: URLRequest
    
    typealias E = Uploadable
    func subscribe<O:ObserverType>(_ observer: O) -> Disposable where O.E == E {
        return Observable.create { [unowned self] observer  in
            Alamofire.request(self.request).responseData(completionHandler: { data in
                observer.on(.next(UploadableFromData(data: data.data!)))
                observer.on(.completed)
            })
            return Disposables.create()
            }.subscribe(observer)
        
    }

    
    init(with poshik: UploadablePoshik ) {
        let url = URL(string:"http://kulon.jwma.ru/api/v1/\(poshik.imageRoute)/set/\(poshik.id)")!
        request = try! URLRequest(url: url,
                   method: .get,
                   headers: ["Authorization": "Bearer \(TokenService().token!)"])
    }
}
