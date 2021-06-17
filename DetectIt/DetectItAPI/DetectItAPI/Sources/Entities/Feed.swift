//
//  Feed.swift
//  DetectItAPI
//
//  Created by Илья Харабет on 26/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation
import DetectItCore

public struct Feed: Codable {
    public var items: [Item]
    public let completedItemsInfo: CompletedItemsInfo?
}

public extension Feed {
    
    struct Item: Codable {
        public let id: String
        public let kind: Kind
        public let title: String
        public let subtitle: String?
        public let picture: String?
        public let difficulty: Int
        public let score: Int?
        public let maxScore: Int
        public let completed: Bool
        public let rating: Double?
        public let cipher: DecoderTask?
        public let profile: ProfileTask?
        public let bundle: TasksBundle.Info?
        public let quest: QuestTask?
    }
    
    struct CompletedItemsInfo: Codable {
        public let count: Int
        public let totalScore: Int
        public let maxTotalScore: Int
    }
    
}

public extension Feed.Item {
    
    enum Kind: String, Codable {
        case bundle
        case cipher
        case profile
        case quest
    }
    
}
