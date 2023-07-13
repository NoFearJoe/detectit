//
//  ProfileTask.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

/// Задание "Расследование".
public struct ProfileTask: Codable {
    
    /// Идентификатор задания.
    public let id: String
    
    /// Название задания.
    public let title: String
    
    /// Вводные данные.
    public let preposition: String
    
    /// Объяснение преступления (после завершения задания).
    public let crimeDescription: String
    
    /// Список случаев.
    public var cases: [Case]
    
    /// Список приложений.
    public var attachments: [Attachment]?
    
    /// Список вопросов.
    public let questions: [Question]
    
    let difficulty: Int
    
}

extension ProfileTask: Task {
    
    public var kind: TaskKind {
        .profile
    }
    
    /// Сложность задания.
    public var taskDifficulty: TaskDifficulty {
        TaskDifficulty(rawValue: difficulty)
    }
    
}

extension ProfileTask: TaskScoring {
    
    /// Максимальное возможное количество очков за правильные ответы.
    public var maxScore: Int {
        questions.reduce(0, { $0 + $1.score })
    }
    
}
