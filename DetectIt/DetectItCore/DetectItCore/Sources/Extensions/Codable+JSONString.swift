//
//  Codable+JSONString.swift
//  DetectItCore
//
//  Created by Илья Харабет on 26.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Foundation

public extension Encodable {
    
    var jsonString: String? {
        guard
            let encodedTask = try? JSONEncoder().encode(self),
            let obj = try? JSONSerialization.jsonObject(with: encodedTask, options: .allowFragments),
            let data = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
        else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
}
