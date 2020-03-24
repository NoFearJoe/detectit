//
//  TasksBundles.swift
//  DetectItCore
//
//  Created by Илья Харабет on 21/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

enum TasksBundles: String, CaseIterable {
    case starter
}

extension TasksBundles: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .starter: return "Стартовый набор"
        }
    }
    
}
