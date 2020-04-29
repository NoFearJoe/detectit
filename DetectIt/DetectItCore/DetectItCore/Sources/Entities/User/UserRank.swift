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
    
    var title: String {
        switch self {
        case .trainee:
            return "user_rank_trainee".localized
        case .juniorDetective:
            return "user_rank_junior_detective".localized
        case .midleDetective:
            return "user_rank_midle_detective".localized
        case .seniorDetective:
            return "user_rank_senior_detective".localized
        case .fatherBrown:
            return "user_rank_father_brown".localized
        case .herculePoirot:
            return "user_rank_hercule_poirot".localized
        case .sherlokHolmes:
            return "user_rank_sherlok_holmes".localized
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
