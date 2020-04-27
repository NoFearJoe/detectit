//
//  TaskKind.swift
//  DetectItCore
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

public enum TaskKind: String {
    case cipher, profile, quest
    
    public var title: String {
        switch self {
        case .cipher:
            return "Шифр"
        case .profile:
            return "Расследование"
        case .quest:
            return "Квест"
        }
    }
    
}
