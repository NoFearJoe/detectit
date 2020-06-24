//
//  Leaderboard.swift
//  DetectItAPI
//
//  Created by Илья Харабет on 22/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation
import DetectItCore

public struct Leaderboard: Codable {
    public let items: [Item]
    public let userPosition: Int?
    public let userItem: Item?
}

public extension Leaderboard {
    
    struct Item: Codable {
        public let alias: String
        public let score: Int
        public let correctAnswersPercent: Double
    }
    
}

public extension Leaderboard {
    
    static let mock = Leaderboard(
        items: Array<Item>(
            repeating: Leaderboard.Item(
                alias: "Mock",
                score: Int.random(in: 0...100),
                correctAnswersPercent: Double.random(in: 0...100)
            ),
            count: 25
        ),
        userPosition: Int.random(in: 24...26),
        userItem: Leaderboard.Item(
            alias: User.shared.alias ?? "",
            score: 1002,
            correctAnswersPercent: 50.53
        )
    )
    
}
