//
//  TasksBundle.swift
//  DetectItCore
//
//  Created by Илья Харабет on 21/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

enum TasksBundle: Int, CaseIterable {
    case starter = 0
}

extension TasksBundle: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .starter: return "Стартовый набор"
        }
    }
    
}
