//
//  ExtraEvidenceTask.swift
//  DetectItCore
//
//  Created by Илья Харабет on 22/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

/// Задание "Выбор лишней улики".
public struct ExtraEvidenceTask: Codable {
    
    /// Идентификатор объекта.
    public let id: String
    
    /// Название задания.
    public let title: String
    
    let difficulty: Int
    
    /// Список изображений с уликами.
    let evidencePictures: [EvidencePicture]
    
    /// Ответ.
    public let answer: Answer
    
}

public extension ExtraEvidenceTask {
    
    struct EvidencePicture: Codable {
        
        /// Подпись к приложению.
        public let title: String
        
        /// Название изображения.
        let pictureName: String
        
    }
    
}

public extension ExtraEvidenceTask {
    
    struct Answer: Codable {
        
        /// Описание произошедшего.
        let crimeDescription: String
        
        /// Название правильного изображения с уликой.
        let evidencePictureName: String
        
    }
    
}

// MARK: Resource accessiong

public extension ExtraEvidenceTask {
    
    func evidencePictureURL(picture: EvidencePicture, bundleID: String) -> URL? {
        TasksBundleMap
            .extraEvidenceDirectoryURL(id: id, bundleID: bundleID)?
            .appendingPathComponent(picture.pictureName)
    }
    
}

extension ExtraEvidenceTask: Task {
    
    public var kind: TaskKind {
        .extraEvidence
    }
    
    /// Сложность задания.
    public var taskDifficulty: TaskDifficulty {
        TaskDifficulty(rawValue: difficulty)
    }
    
}

extension ExtraEvidenceTask: TaskScoring {
    
    /// Количество очков за правильный ответ.
    public var maxScore: Int {
        difficulty
    }
    
}
