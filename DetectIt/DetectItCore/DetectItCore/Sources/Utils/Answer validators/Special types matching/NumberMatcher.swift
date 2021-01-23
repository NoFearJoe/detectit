//
//  NumberMatcher.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

struct NumberMatcher: SpecialTypeMatcher {
    
    func match(userAnswer: String, correctAnswer: String) -> MatchingResult {
        if let correctNumber = Int(correctAnswer) {
            guard let userNumber = Int(userAnswer) else { return .notEqual }
            
            return .init(
                correctNumber == userNumber
            )
        } else if let correctNumber = Double(correctAnswer) {
            guard let userNumber = Double(userAnswer) else { return .notEqual }
            
            return .init(
                correctNumber == userNumber
            )
        } else {
            return .skipped
        }
    }
    
}
