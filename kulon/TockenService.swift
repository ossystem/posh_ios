//
//  TockenService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 19/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation

class TokenService {
    
    private let key = "TokenKey"
    
    var token: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
        get {
            return UserDefaults.standard.string(forKey: key)
        }
    }
}
