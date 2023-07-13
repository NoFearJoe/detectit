//
//  TaskKind.swift
//  DetectItCore
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public enum TaskKind: String, Codable {
    case cipher, profile, blitz, quest
    
    public var title: String {
        switch self {
        case .cipher:
            return "task_kind_cipher".localized
        case .profile:
            return "task_kind_profile".localized
        case .blitz:
            return "task_kind_blitz".localized
        case .quest:
            return "task_kind_quest".localized
        }
    }
    
}
