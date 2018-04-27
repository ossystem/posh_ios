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
import ObjectMapper

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
            return "4\(name)#".data(using: .utf8)!
        case let .createImage(name):
            return "0\(name)#".data(using: .utf8)!
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

class FakeEmptyObservableImage: ObservableImage {
    func asObservable() -> Observable<UIImage> {
        return Observable.just(UIImage())
    }
}

class FakeObservableImage: ObservableImage {
    func asObservable() -> Observable<UIImage> {
        return Observable.just(#imageLiteral(resourceName: "sample_poshik_3"))
    }
}

class DefaultUserImage: ObservableImage {
    func asObservable() -> Observable<UIImage> {
        return Observable.just(#imageLiteral(resourceName: "icon_artist_black"))
    }
}



class ObservableImageFromJSON: ObservableImage, ImmutableMappable, ObservableType {

    private var link: String
    
    typealias E = UIImage
    func subscribe<O:ObserverType>(_ observer: O) -> Disposable where O.E == E {
        let request = try! URLRequest(url: URL(string: link)!,
                method: .get,
                headers: ["Authorization": "Bearer \(TokenService().token!)"])
        return Observable.create { [unowned self] observer  in
            Alamofire.request(request).responseData(completionHandler: { data in
                if let data = data.data, let image = UIImage(data: data) {
                    observer.on(.next(image))
                    observer.on(.completed)
                } else {
//                    observer.on(.error(ResponseError(message: "Image error")))
                }
            })
            return Disposables.create()
        }.subscribe(observer)
    }

    required init(map: Map) throws {
        self.link = try map.value("link")
    }
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
        fatalError("poshiks are deprecated")
        let url = URL(string:"http://kulon.jwma.ru/api/v1/set/")!
        request = try! URLRequest(url: url,
                   method: .get,
                   headers: ["Authorization": "Bearer \(TokenService().token!)"])
    }

    
    init(artworkInfo: ArtworkInfo) {
        
        request = try! URLRequest(url: "",
                                  method: .get,
                                  headers: ["Authorization": "Bearer \(TokenService().token!)"])
    }
}
