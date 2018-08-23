//
//  OwnedArtwork.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 03/04/2018.
//  Copyright © 2018 Jufy. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import ObjectMapper

import WatchKit
import WatchConnectivity
import UserNotifications

protocol OwnedArtwork: Artwork, Purchasable, Selectable {
    func setToDevice() -> Observable<Void> //FIXME: TEMP
}

extension OwnedArtwork {
    var purchased: Observable<Void> {
        return Observable.just()
    }
    
    var viewControllerToPresentt: UIViewController {
        return OwnedArtworkController(ownedArtwork: self)
    }
}

class FakeOwnedArtwork: OwnedArtwork {
    var isLiked: Bool = false
    
    func like() -> Observable<Bool> {
        return Observable.never()
    }
    
    func setToDevice() -> Observable<Void> {
        return Observable.just()
    }
    
    var info: Observable<ArtworkInfo> {
        return Observable.just(FakeArtworkInfo())
    }
    
    var image: ArtworkImage = FakeArtworkImage()
    
    var id: String = "-1"
    
    var name: String = "Jaconda"
        var isPurchased: Bool = false
}

protocol OwnedArtworks {
    func asObservable() -> Observable<[OwnedArtwork]>
}

class FakeOwnedArtworks : OwnedArtworks {
    func asObservable() -> Observable<[OwnedArtwork]> {
        return Observable.just([FakeOwnedArtwork()])
    }
}

enum MyError: Error {
    case BadImage
}

class OwnedArtworkFromArtwork: NSObject, OwnedArtwork, UploadablePoshik, WCSessionDelegate {
    var isLiked: Bool {
        return origin.isLiked
    }
    
    
    func like() -> Observable<Bool> {
        return origin.like()
    }
    
    var imageForUpload: Observable<Uploadable> {
        
        return info.asObservable()
            .flatMap { UploadableImage(artworkInfo: $0) }
    }
    
    var id: String
    
    var name: String
    
    var bleService = BLEService.shared
    
    var wcSession: WCSession!
    
    let bag = DisposeBag()
    let wcResult = Variable<Int>(0)
    var wcError : Error?
    var wcFileUrl : URL?
    let wcResultO : Observable<Int>
    
    func setToDevice() -> Observable<Void> {
        if (self.canPutOnWatch(wcSession: wcSession)) {
            
            self.wcResult.value = 0
            self.wcError = nil;
            self.wcFileUrl = nil;
            
            let pr = self.getFileUrl(self)
                .flatMap { (fileUrl: URL) -> Observable<Int> in
                    self.wcFileUrl = fileUrl
                    self.wcSession.transferFile(fileUrl, metadata: ["fileMetadata": "123"])
                    return self.wcResultO
                }
                .skipWhile({ (res: Int) -> Bool in
                    return res == 0;
                })
                .flatMap { (res: Int) -> Observable<Void> in
                    if (res == 1) {
                        return Observable.just()
                    } else if (res == -1) {
                        return Observable.error(self.wcError!)
                    } else {
                        return Observable.empty()
                    }
                }
            
                return pr
        } else {
            return bleService.set(self)
        }
    }

    //TODO: background fetch
    /*
        return Observable.create({  observer in
            
            DispatchQueue.global().async {
                if let image = gif(data: data) {
                    observer.onNext(image)
                } else {
                    observer.onError(ImageErorr())
                }
            }
            return Disposables.create()
        })
   */
    
    func getFileUrl(_ poshik: UploadablePoshik & NamedObject) -> Observable<URL> {
        
        let file = poshik.imageForUpload
        let infoO = self.origin.info
        
        //this doesn't work for animated files :(
        /*
        return file.asObservable().flatMap { file -> Observable<URL> in
            let imageData: NSData
            imageData = file.data as NSData;
            if imageData.length < 2000 {
                return Observable.error(MyError.BadImage)
            }
            let directory = NSTemporaryDirectory()
            let fileName = poshik.name //NSUUID().uuidString
            let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
            do {
                try imageData.write(to: fullURL!)
            } catch {
                return Observable.error(error)
            }
            return Observable.from(optional: fullURL)
        }
        */
        
        return infoO.flatMap { info -> Observable<URL> in
            let imageDownloadUrl = URL(string: info.image.link)
            var imageData: Data?;
            var err : Error?;
            
            do {
                //TODO: background fetch
                imageData = try Data(contentsOf: imageDownloadUrl!)
            } catch {
                err = error
            }
            if (err != nil) {
                return Observable.error(err!)
            }
            if imageData == nil || (imageData?.count)! < 3000 {
                return Observable.error(MyError.BadImage)
            }
            
            let directory = NSTemporaryDirectory()
            let fileName = poshik.name //NSUUID().uuidString
            let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
            
            do {
                try imageData?.write(to: fullURL!)
            } catch {
                err = error
            }
            if (err != nil) {
                return Observable.error(err!)
            }
            
            return Observable.from(optional: fullURL)
        }
 
    }
    
    var info: Observable<ArtworkInfo> {
        return origin.info
    }
    
    var image: ArtworkImage {
        return origin.image
    }
    
    var purchased: Observable<Void> {
        return Observable.just()
    }
    
    var isPurchased: Bool {
        return origin.isPurchased
    }
    
    private var origin: Artwork
    
    init(artwork: Artwork) {
        let format = artwork.image.mime == "image/gif" ? "mjpeg" : "jpeg"
        self.origin = artwork
        self.name = "\(artwork.name).\(format)"
        self.id = artwork.id
        
        self.wcResultO = self.wcResult.asObservable()
        self.wcError = nil
        self.wcFileUrl = nil
        
        super.init()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default()
            wcSession.delegate = self
            wcSession.activate()
        }
    
    }
    

    func canPutOnWatch(wcSession: WCSession) -> Bool {
        //return true;
        return WCSession.isSupported() && wcSession.isPaired && wcSession.isWatchAppInstalled;
    }
    

    // MARK: WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error != nil {
            print("[!] WC session activation error: \(error?.localizedDescription ?? "-")")
        } else {
            print("[i] WC session activated \(activationState)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("[i] WC session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("[i] WC session did deactivate")
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if (self.wcFileUrl != fileTransfer.file.fileURL) {
            print("[?] WC file transfer not our callback   \(error?.localizedDescription ?? "-")")
            return
        }
        
        if error != nil {
            print("[!] WC session file transfer error: \(error?.localizedDescription ?? "-")")
            self.wcError = error
            self.wcResult.value = -1
        } else {
            print("[i] WC finished file transfer")
            self.wcResult.value = 1
        }
    }
    
}

class OwnedArtworksFromAPI: OwnedArtworks {
    func asObservable() -> Observable<[OwnedArtwork]> {
        return OwnedArtworksApiService().request(parameter: ParameterNone()).map {
            $0.artworks.map { OwnedArtworkFromArtwork(artwork: $0) }
        }
    }
}



class OwnedArtworksApiService: ApiService {
    
    typealias Parameter = ParameterNone
    typealias Response = OwnedArtworksFromJSON
    
    var route: String = "artworks/owned"
    var method: Alamofire.HTTPMethod = .get
}



class OwnedArtworksFromJSON: ResponseType {
    let artworks: [OwnedArtworkFromJSON]
    
    required init(map: Map) throws {
        artworks = try map.value("purchases") as [OwnedArtworkFromJSON]
    }
}

class OwnedArtworkFromJSON: Artwork, ResponseType {
    var isLiked: Bool
    
    var info: Observable<ArtworkInfo> {
        return ObservableOwnedArtworkInfo(artwork: self).asObservable().map { $0 as ArtworkInfo }
    }
    
    var image: ArtworkImage
    
    var id: String
    
    var name: String
    
    var isPurchased: Bool
    
    private lazy var likeService = LikeApiService(artwork: self)
    private lazy var dislikeService = DisikeApiService(artwork: self)
    
    func like() -> Observable<Bool> {
        if isLiked {
            return dislikeService.request(parameter: ParameterNone())
                .map{ _ in
                    self.isLiked = false
                    return false
            }
        } else {
            return likeService.request(parameter: ParameterNone())
                .map {_ in
                    self.isLiked = true
                    return true
            }
        }
    }
    
    required init(map: Map) throws {
        
          //FIXME: to handle purchases
            id = try map.value("artwork.id")
            name = try map.value("artwork.name")
            image = try map.value("artwork.image") as ArtworkImageFromJSON
            isPurchased = true
            isLiked = try map.value("artwork.is_favorite")
    }
}

class ObservableOwnedArtworkInfo {
    
    func asObservable() -> Observable<ArtworkInfoFromJSON> {
        return artworkInfoApiService.request(parameter: ParameterNone())
    }
    private var artworkInfoApiService : OwnedArtworkInfoApiService
    init(artwork: Artwork) {
        self.artworkInfoApiService = OwnedArtworkInfoApiService(artwork: artwork)
    }
    
}


class OwnedArtworkInfoApiService: ApiService {
    typealias Response = ArtworkInfoFromJSON
    typealias Parameter = ParameterNone
    
    var route: String
    var method: HTTPMethod = .get
    
    init(artwork: Artwork) {
        route = "artworks/owned/\(artwork.id)"
    }
    
}
