//
//  Poshik.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 08/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper


enum ImageSize: String {
    case big = "big", middle = "middle", small = "small"
}

protocol Poshik: IdiableObject {
    var name : String { get }
    var isLiked: Bool { get set }
    var isPurchased: Bool { get set }
    var imageRoute: String { get }
    var fileType: String { get }
    func requestforImage(withSize size: ImageSize) -> URLRequest?
    
}

extension Poshik {
    
    var name: String {
        return "\(id).\(fileType)"
    }
    
    func requestforImage(withSize size: ImageSize) -> URLRequest? {
        let url = URL(string: "http://kulon.jwma.ru/api/v1/\(imageRoute)/\(id)/img?size=\(size.rawValue)")
        
        return try? URLRequest(url: url!, method: .get, headers: ["Authorization": "Bearer \(TokenService().token!)"])
        
    }
    
}

protocol UploadablePoshik : Poshik {
    var imageForUpload: ObservableUploadable { get }
}

class PoshikFromMarket: Poshik {
    
    var isPurchased: Bool = false
    var isLiked: Bool = false
    var imageRoute: String = "market"
    var id: String = "-1"
    var fileType: String
    
    required init(map: Map) throws {
        id <- map["id"]
        isLiked <- map["is_favorite"]
        isPurchased <- map["is_purchased"]
        fileType = try map.value("extension")
        if fileType != "jpg" {
            fileType = "mjpeg"
        }
    }
    
}

class MyPoshikFromMarket: UploadablePoshik {
    
    lazy var imageForUpload: ObservableUploadable = UploadableImage(with: self)
    
    var isPurchased: Bool = true
    var isLiked: Bool = false
    var imageRoute: String = "poshiks/purchase"
    var id: String = "-1"
    var fileType: String
    
    
    required init(map: Map) throws {
        id <- map["id"]
        isLiked <- map["is_favorite"]
        isPurchased <- map["is_purchased"]
        fileType = try map.value("extension")
        if fileType != "jpg" {
            fileType = "mjpeg"
        }

    }
    
    init(fromMarket poshik: Poshik) {
        id = poshik.id
        isLiked = poshik.isLiked
        fileType = poshik.fileType
        if fileType != "jpg" {
            fileType = "mjpeg"
        }
    }
}

class MyPoshikUploaded: UploadablePoshik {
    lazy var imageForUpload: ObservableUploadable = UploadableImage(with: self)

    
    var isPurchased: Bool = true
    var isLiked: Bool = false
    var imageRoute: String = "poshiks/my"
    var id: String = "-1"
    var fileType: String
    
    required init(map: Map) throws {
        id <- map["id"]
        isLiked <- map["is_favorite"]
        isPurchased <- map["is_purchased"]
        fileType = try map.value("extension")
    }
}

class FavoritePoshik: Poshik {
    var isPurchased: Bool = false
    var isLiked: Bool = true
    var imageRoute: String = "market"
    var id: String = "-1"
    var fileType: String
    
    required init(map: Map) throws {
        id <- map["id"]

        fileType = try map.value("extension")
        if fileType != "jpg" {
            fileType = "mjpeg"
        }
    }
}

