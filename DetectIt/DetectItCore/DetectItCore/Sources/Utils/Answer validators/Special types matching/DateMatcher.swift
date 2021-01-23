//
//  DateMatcher.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

struct DateMatcher: SpecialTypeMatcher {
    
    func match(userAnswer: String, correctAnswer: String) -> MatchingResult {
        guard let correctDate = Date(dateString: correctAnswer) else { return .skipped }
        guard let userDate = Date(dateString: userAnswer) else { return .notEqual }
        
        return .init(userDate == correctDate)
    }
    
}
