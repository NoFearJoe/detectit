//
//  Array+Unique.swift
//  DetectItCore
//
//  Created by Илья Харабет on 21.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Foundation

public extension Array where Element: Equatable {
    
    var unique: [Element] {
        reduce([Element]()) { result, element in
            guard !result.contains(element) else { return result }
            
            return result.isEmpty ? [element] : result + [element]
        }
    }
    
}
