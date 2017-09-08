//
//  UserCredentialsService.swift
//  kulon
//
//  Created by Артмеий Шлесберг on 21/05/2017.
//  Copyright © 2017 Jufy. All rights reserved.
//

import Foundation

class UserCredentialsService {
    
    private let credentialsKey = "UserCredentialsKey"
    private let loggedInKey = "isLoggedInKey"
    private let userDefaults = UserDefaults.standard
    
    var credentials: UserCredentials? {
        set {
            guard let newValue = newValue else {return}
            userDefaults.set(newValue.toJSON(), forKey: credentialsKey)
        }
        get {
            guard let dict = userDefaults.dictionary(forKey: credentialsKey) else { return nil }
            return UserCredentials(from: dict)
        }
    }
    
    var isLoggedIn: Bool {
        set {
            userDefaults.set(newValue, forKey: loggedInKey)
        }
        get {
            return userDefaults.bool(forKey: loggedInKey)
        }
    }
}
