//
//  MatchingResult.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

enum MatchingResult {
    case equal, notEqual, skipped
    
    init(_ bool: Bool) {
        self = bool ? .equal : .notEqual
    }
    
    var bool: Bool? {
        switch self {
        case .equal: return true
        case .notEqual: return false
        case .skipped: return nil
        }
    }
}
