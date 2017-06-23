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
    
    var isLiked: Bool { get set }
    var isPurchased: Bool { get set }
    var imageRoute: String { get }
    func requestforImage(withSize size: ImageSize) -> URLRequest?
}

extension Poshik {
    
    func requestforImage(withSize size: ImageSize) -> URLRequest? {
        let url = URL(string: "http://kulon.jwma.ru/api/v1/\(imageRoute)/\(id)/img?size=\(size.rawValue)")
        
        return try? URLRequest(url: url!, method: .get, headers: ["Authorization": "Bearer \(TokenService().token!)"])
        
    }
    
}

class PoshikFromMarket: Poshik {
    
    var isPurchased: Bool = false
    var isLiked: Bool = false
    var imageRoute: String = "market"
    var id: Int = -1
    
    required init(map: Map) throws {
        id <- map["id"]
        isLiked <- map["is_favorite"]
        isPurchased <- map["is_purchased"]
    }
    
}

class MyPoshikFromMarket: Poshik {
    
    var isPurchased: Bool = false
    var isLiked: Bool = false
    var imageRoute: String = "poshiks/purchase"
    var id: Int = -1
    
    required init(map: Map) throws {
        id <- map["id"]
        isLiked <- map["is_favorite"]
        isPurchased <- map["is_purchased"]
    }
}

class MyPoshikUploaded: Poshik {
    
    var isPurchased: Bool = false
    var isLiked: Bool = false
    var imageRoute: String = "poshiks/my"
    var id: Int = -1
    
    required init(map: Map) throws {
        id <- map["id"]
        isLiked <- map["is_favorite"]
        isPurchased <- map["is_purchased"]
    }
}

