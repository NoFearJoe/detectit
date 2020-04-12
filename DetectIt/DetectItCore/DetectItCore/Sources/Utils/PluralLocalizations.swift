//
//  PluralLocalizations.swift
//  DetectItCore
//
//  Created by Илья Харабет on 12/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public struct Plurals {
    
    public static func score(_ score: Int) -> String {
        if (11...14).contains(score % 100) {
            return "\(score) очков"
        }
        
        switch score % 10 {
        case 1:
            return "\(score) очко"
        case 2...4:
            return "\(score) очка"
        default:
            return "\(score) очков"
        }
    }
    
}
