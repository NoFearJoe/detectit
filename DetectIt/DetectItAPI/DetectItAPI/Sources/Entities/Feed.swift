//
//  Feed.swift
//  DetectItAPI
//
//  Created by Илья Харабет on 26/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public struct Feed: Codable {
    public let items: [Item]
}

public extension Feed {
    
    struct Item: Codable {
        public let id: String
        public let kind: Kind
        public let title: String
        public let subtitle: String?
        public let picture: String?
        public let difficulty: Int
        public let isSolved: Bool
        public let score: Int?
        public let maxScore: Int
    }
    
}

public extension Feed.Item {
    
    enum Kind: String, Codable {
        case bundle
        case cipher
        case profile
    }
    
}
