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
    let encodedPictureName: String?
    
    /// Название аудиофайла
    let encodedAudioName: String?
    
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

public extension DecoderTask {

    enum DecodedResource {
        case nothing
        case picture(path: String)
        case audio(path: String)
        case pictureAndAudio(picturePath: String, audioPath: String)
    }
    
    var decodedResource: DecodedResource {
        if let picture = encodedPictureName, let audio = encodedAudioName, !picture.isEmpty, !audio.isEmpty {
            return .pictureAndAudio(picturePath: picture, audioPath: audio)
        } else if let picture = encodedPictureName, !picture.isEmpty {
            return .picture(path: picture)
        } else if let audio = encodedAudioName, !audio.isEmpty {
            return .audio(path: audio)
        } else {
            return .nothing
        }
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
        clear(decodedMessage) == clear(answer)
            || possibleAnswers?.map { clear($0) }.contains(clear(answer)) == true
    }
    
    private func clear(_ answer: String) -> String {
        answer
            .filter { !$0.isWhitespace && !$0.isNewline && ![",", "\"", "'", "«", "»"].contains($0) }
            .lowercased()
    }
    
}
