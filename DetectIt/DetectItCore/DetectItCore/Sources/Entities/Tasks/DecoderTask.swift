//
//  DecoderTask.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

/// Задание "Дешифратор".
public struct DecoderTask: Codable {
    
    /// Идентификатор задания.
    public let id: String
    
    /// Название задания.
    public let title: String
    
    /// Вводные данные.
    public let preposition: String
    
    let difficulty: Int
    
    /// Количество очков за правильный ответ (1-5).
    let score: Int
    
    /// Название закодированного изображения.
    let encodedPictureName: String
    
    /// Ответ.
    public let answer: Answer
    
}

public extension DecoderTask {
    
    struct Answer: Codable {
        
        /// Описание ответа.
        public let crimeDescription: String
        
        /// Расшифрованное сообщение.
        public let decodedMessage: String
        
        /// Ответы в зачет.
        public let possibleAnswers: [String]?
        
    }
    
}

// MARK: - Resource accessing

public extension DecoderTask {
    
    func encodedPictureURL(bundleID: String) -> URL? {
        TasksBundleMap
            .cipherDirectoryURL(id: id, bundleID: bundleID)?
            .appendingPathComponent(encodedPictureName)
    }
    
}

extension DecoderTask: Task {
    
    public var kind: TaskKind {
        .cipher
    }
    
    /// Сложность задания.
    public var taskDifficulty: TaskDifficulty {
        TaskDifficulty(rawValue: difficulty)
    }
    
}

extension DecoderTask: TaskScoring {
    
    /// Максимальное количество очков, которое можно получить за правильный ответ.
    public var maxScore: Int {
        score
    }
    
}

public extension DecoderTask.Answer {
    
    func compare(with answer: String) -> Bool {
        let clearAnswer = answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return decodedMessage.lowercased() == clearAnswer || possibleAnswers?.map { $0.lowercased() }.contains(clearAnswer) == true
    }
    
}
