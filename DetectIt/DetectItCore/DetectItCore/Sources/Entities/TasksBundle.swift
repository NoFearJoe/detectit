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
    }
    
    public let info: Info
    private let ciphers: [DecoderTask]?
    private let profiles: [ProfileTask]?
    
    public var decoderTasks: [DecoderTask] {
        ciphers ?? []
    }
    
    public var profileTasks: [ProfileTask] {
        profiles ?? []
    }
    
    public var questTasks: [QuestTask] {
        []
    }
    
}

public extension TasksBundle {
    
    /// Максимальное количество очков, которое можно получить за правильное решение всех заданий.
    var maxScore: Int {
        [
            decoderTasks,
            profileTasks,
            questTasks
        ]
            .compactMap { $0 as? [TaskScoring] }
            .reduce(0, {
                $0 + $1.reduce(0, { $0 + $1.maxScore })
            })
    }
    
}
