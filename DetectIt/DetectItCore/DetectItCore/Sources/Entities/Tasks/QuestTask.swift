//
//  QuestTask.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

/// Задание "Квест".
public struct QuestTask: Codable {
    
    /// Идентификатор задания.
    public let id: String
    
    /// Название задания.
    public let title: String
    
    /// Вводные данные.
    public let preposition: String
    
    /// Главы квеста.
    public let chapters: [Chapter]
    
    /// Концовки квеста.
    public let endings: [Ending]
    
    let difficulty: Int
    
}

public extension QuestTask {
    
    /// Глава квеста.
    struct Chapter: Codable {
        
        /// Идентификатор главы.
        public let id: String
        
        /// Текст главы.
        public let text: String
        
        /// Действия.
        public let actions: [Action]
        
    }
    
}

public extension QuestTask.Chapter {
    
    /// Действие, которое можно совершить в главе.
    struct Action: Codable {
        
        /// Идентификатор действия.
        public let id: String
        
        /// Заголовок действия.
        public let title: String
        
        /// Идентификатор главы, к которой ведет это действие.
        /// Если `nil`, то действие ведет к концовке.
        public let targetChapterID: String?
        
        /// Идентификатор концовки, к которой ведет это действие.
        /// Если `nil`, то действие ведет к следующей главе.
        public let targetEndingID: String?
        
    }
    
}

public extension QuestTask {

    /// Концовка квеста.
    struct Ending: Codable {
        
        /// Идентификатор концовки.
        public let id: String
        
        /// Текст концовки.
        public let text: String
        
        /// Количество очков за достижение этой концовки.
        public let score: Int
        
    }

}

extension QuestTask: TaskScoring {
    
    /// Максимальное количество очков, которое возможно набрать, дойдя до лучшей концовки.
    public var maxScore: Int {
        endings.map { $0.score }.max() ?? 0
    }
    
}

public extension QuestTask {
    
    /// Сложность задания.
    var taskDifficulty: TaskDifficulty {
        TaskDifficulty(rawValue: difficulty)
    }
    
}
