//
//  TaskKind+Icon.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04.12.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

public extension TaskKind {
    
    var icon: UIImage? {
        switch self {
        case .cipher:
            return UIImage.asset(named: "cipher_task_icon")
        case .profile:
            return UIImage.asset(named: "profile_task_icon")
        case .blitz:
            return UIImage.asset(named: "blitz_task_icon")
        case .quest:
            return UIImage.asset(named: "quest_task_icon")
        }
    }
    
}
