//
//  TaskDifficulty+Icon.swift
//  DetectItUI
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

public extension TaskDifficulty {
    
    var icon: UIImage {
        switch self {
        case .easy:
            return UIImage.asset(named: "OneStar")!
        case .normal:
            return UIImage.asset(named: "TwoStars")!
        case .hard:
            return UIImage.asset(named: "ThreeStars")!
        case .nightmare:
            return UIImage.asset(named: "Nightmare")!
        }
    }
    
}
