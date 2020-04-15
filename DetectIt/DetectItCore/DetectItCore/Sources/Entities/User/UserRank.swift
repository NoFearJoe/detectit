//
//  UserRank.swift
//  DetectItCore
//
//  Created by Илья Харабет on 15/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public enum UserRank: CaseIterable {
    case trainee
    case juniorDetective
    case midleDetective
    case seniorDetective
    case fatherBrown
    case herculePoirot
    case sherlokHolmes
}

public extension UserRank {
    
    init(score: Int) {
        self = Self.allCases.first(where: { $0.score.contains(score) }) ?? .trainee
    }
    
}

public extension UserRank {
    
    // TODO
    var title: String {
        switch self {
        case .trainee:
            return "Стажер"
        case .juniorDetective:
            return "Младший детектив"
        case .midleDetective:
            return "Детектив"
        case .seniorDetective:
            return "Старший детектив"
        case .fatherBrown:
            return "Отец Браун"
        case .herculePoirot:
            return "Эркюль Пуаро"
        case .sherlokHolmes:
            return "Шерлок Холмс"
        }
    }
    
    var score: Range<Int> {
        switch self {
        case .trainee:
            return Int.min..<25
        case .juniorDetective:
            return 25..<50
        case .midleDetective:
            return 50..<100
        case .seniorDetective:
            return 100..<200
        case .fatherBrown:
            return 200..<500
        case .herculePoirot:
            return 500..<1000
        case .sherlokHolmes:
            return 1000..<Int.max
        }
    }
    
}
