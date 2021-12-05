//
//  BlitzTask.swift
//  DetectItCore
//
//  Created by Илья Харабет on 20.11.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Foundation

/// Задание "Блиц".
public struct BlitzTask: Codable {
    
    let difficulty: Int
    
    /// Идентификатор задания.
    public let id: String
        
    /// Название задания.
    public let title: String
    
    /// Вводные данные.
    public let preposition: String
    
    /// Текст задания.
    public let taskText: String
    
    /// Список приложений.
    public let attachments: [ProfileTask.Attachment]?
    
    /// Список вопросов.
    public let question: ProfileTask.Question
    
    /// Объяснение преступления (после завершения задания).
    public let crimeDescription: String
    
    /// Список приложений к объяснению задания.
    public let crimeDescriptionAttachments: [ProfileTask.Attachment]?
        
}

extension BlitzTask: Task {
    
    public var kind: TaskKind {
        .blitz
    }
    
    /// Сложность задания.
    public var taskDifficulty: TaskDifficulty {
        TaskDifficulty(rawValue: difficulty)
    }
    
}

extension BlitzTask: TaskScoring {
    
    /// Максимальное возможное количество очков за правильные ответы.
    public var maxScore: Int {
        question.score
    }
    
}
