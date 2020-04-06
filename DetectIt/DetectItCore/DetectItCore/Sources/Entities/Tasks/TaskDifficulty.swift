//
//  TaskDifficulty.swift
//  DetectItCore
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public enum TaskDifficulty: Int {
    case easy = 1
    case normal = 2
    case hard = 3
    case nightmare = 5
    
    public init(rawValue: Int) {
        switch rawValue {
        case 2:
            self = .normal
        case 3:
            self = .hard
        case 5:
            self = .nightmare
        default:
            self = .easy
        }
    }
}
