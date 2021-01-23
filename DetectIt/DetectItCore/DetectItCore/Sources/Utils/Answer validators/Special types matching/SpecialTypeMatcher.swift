//
//  SpecialTypeMatcher.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

protocol SpecialTypeMatcher {
    func match(userAnswer: String, correctAnswer: String) -> MatchingResult
}
