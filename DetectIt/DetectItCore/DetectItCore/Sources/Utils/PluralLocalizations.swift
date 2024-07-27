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
    
    public static func attempts(_ count: Int) -> String {
        if (11...14).contains(count % 100) {
            return "Осталось \(count) попыток"
        }
        
        switch count % 10 {
        case 1:
            return "Последняя попытка"
        case 2...4:
            return "Осталось \(count) попытки"
        default:
            return "Осталось \(count) попыток"
        }
    }
}
