//
//  DetectiveProfile.swift
//  DetectItAPI
//
//  Created by Илья Харабет on 21/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

public struct DetectiveProfile: Codable {
    public let positionInRating: Int
    public let correctAnswersPercent: Double
    public let totalScore: Int
    public let solvedTasksCount: Int
}
