//
//  TasksBundle.swift
//  DetectItCore
//
//  Created by Илья Харабет on 24/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public struct TasksBundle: Codable {
    
    public struct Info: Codable {
        public let id: String
        public let title: String
        public let description: String
        public let action: Action?
    }
    
    public struct TaskScore: Codable {
        public let taskID: String
        public let score: Int?
    }
    
    public let info: Info
    private let ciphers: [DecoderTask]?
    private let profiles: [ProfileTask]?
    private let blitzs: [BlitzTask]?
    private let quests: [QuestTask]?
    
    public let taskScores: [TaskScore]?
    
    public var decoderTasks: [DecoderTask] {
        ciphers ?? []
    }
    
    public var profileTasks: [ProfileTask] {
        profiles ?? []
    }
    
    public var blitzTasks: [BlitzTask] {
        blitzs ?? []
    }
    
    public var questTasks: [QuestTask] {
        quests ?? []
    }
    
}

public extension TasksBundle.Info {
    
    struct Action: Codable {
        public let title: String
        public let titleColor: String
        public let backgroundColor: String
        public let link: String
    }
    
}

public extension TasksBundle {
    
    /// Максимальное количество очков, которое можно получить за правильное решение всех заданий.
    var maxScore: Int {
        [
            decoderTasks,
            profileTasks,
            blitzTasks,
            questTasks
        ]
            .compactMap { $0 as? [TaskScoring] }
            .reduce(0, {
                $0 + $1.reduce(0, { $0 + $1.maxScore })
            })
    }
    
}
