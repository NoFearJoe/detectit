//
//  TasksBundles+Info.swift
//  DetectIt
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension TasksBundles {
    
    var image: UIImage {
        switch self {
        case .starter:
            return UIImage.asset(named: "Test")! // TODO: Get image from bundle
        case .bundle1:
            return UIImage.asset(named: "Test")!
        case .bundle2:
            return UIImage.asset(named: "Test")!
        }
    }
    
    var title: String {
        switch self {
        case .starter:
            return "Для начала"
        case .bundle1:
            return "Игра #1"
        case .bundle2:
            return "Игра #2"
        }
    }
    
    var description: String {
        switch self {
        case .starter:
            return "Легкие задания для дурачков, таких как ты"
        case .bundle1:
            return ""
        case .bundle2:
            return "Текст"
        }
    }
    
}
