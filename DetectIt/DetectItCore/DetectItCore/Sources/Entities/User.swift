//
//  User.swift
//  DetectItCore
//
//  Created by Илья Харабет on 14/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public final class User {
    
    public static let shared = User()
    
    public var alias: String? {
        get {
            UserDefaults.standard.string(forKey: "user_alias")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "user_alias")
        }
    }
    
}
