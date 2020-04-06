//
//  AudioRecordTask.swift
//  DetectIt
//
//  Created by Илья Харабет on 21/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

/// Задание "Аудиозапись".
public struct AudioRecordTask: Codable {
    
    /// Идентификатор объекта.
    public let id: String
    
    /// Название задания.
    public let title: String
    
    let difficulty: Int
    
    /// Название аудиофайла для проигрывания.
    let audioFileName: String
    
    /// Словарь со списком типов преступлений, подходящих для данной аудиозаписи.
    /// Словарь хранится в бандле, не в директории с заданием.
    let crimeTypesDictionary: String
    
    /// Словарь со списком мест преступлений, подходящих для данной аудиозаписи.
    /// Словарь хранится в бандле, не в директории с заданием.
    let crimePlacesDictionary: String
    
    /// Ответ.
    public let answer: Answer
    
}

public extension AudioRecordTask {
    
    struct Answer: Codable {
        
        /// Описаний произошедшего.
        public let crimeDescription: String
        
        /// Тип преступления.
        public let crimeType: String
        
        /// Место преступления.
        public let crimePlace: String
        
        /// Количество участников.
        public let criminalsCount: Int
        
    }
    
}

// MARK: - Resource accessing

public extension AudioRecordTask {
    
    func audioFileURL(bundleID: String) -> URL? {
        TasksBundleMap
            .audiorecordDirectoryURL(id: id, bundleID: bundleID)?
            .appendingPathComponent(audioFileName)
    }
    
    func crimeTypesDictionaryURL(bundleID: String) -> URL? {
        TasksBundleMap
            .dictionariesDirectoryURL(bundleID: bundleID)?
            .appendingPathComponent(crimeTypesDictionary)
    }
    
    func crimePlacesDictionaryURL(bundleID: String) -> URL? {
        TasksBundleMap
            .dictionariesDirectoryURL(bundleID: bundleID)?
            .appendingPathComponent(crimePlacesDictionary)
    }
    
}

extension AudioRecordTask: Task {
    
    public var kind: TaskKind {
        .audiorecord
    }
    
    /// Сложность задания.
    public var taskDifficulty: TaskDifficulty {
        TaskDifficulty(rawValue: difficulty)
    }
    
}

extension AudioRecordTask: TaskScoring {
    
    public var scoreForCrimeType: Int { 1 }
    public var scoreForCrimePlace: Int { 1 }
    public var scoreForCriminalsCount: Int { 1 }
    
    /// Максимальное количество очков за верные ответы.
    public var maxScore: Int {
        scoreForCrimeType + scoreForCrimePlace + scoreForCriminalsCount
    }
    
}
