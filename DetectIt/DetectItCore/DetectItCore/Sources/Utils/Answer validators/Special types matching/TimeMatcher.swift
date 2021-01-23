//
//  TimeMatcher.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

struct TimeMatcher: SpecialTypeMatcher {
    
    private static let timeSeparators = [":", "-", "/"]
    
    func match(userAnswer: String, correctAnswer: String) -> MatchingResult {
        guard
            let correctTime = Date(timeString: correctAnswer)
        else {
            return .skipped
        }
        
        if let answeredTime = Date(timeString: userAnswer), correctTime.compareTime(with: answeredTime) {
            return .equal
        }
        
        let answeredTimeComponents = userAnswer
            .split(whereSeparator: {
                Self.timeSeparators.contains(String($0))
            })
            .map { String($0) }
        
        return .init(correctTime.compareTime(with: answeredTimeComponents))
    }
    
}
