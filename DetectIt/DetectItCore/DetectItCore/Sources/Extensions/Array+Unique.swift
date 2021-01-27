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

public extension Array {
    
    func unique(include: @escaping (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element] {
        reduce([]) { acc, element in
            acc.contains(where: { include(element, $0) }) ? acc : acc + [element]
        }
    }
    
}

public extension Array {
    
    func item(at index: Int) -> Element? {
        guard (0..<count) ~= index else { return nil }
        return self[index]
    }
    
}
