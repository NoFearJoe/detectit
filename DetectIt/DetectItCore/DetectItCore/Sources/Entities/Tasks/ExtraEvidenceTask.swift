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
    
    /// Список названий изображений с уликами.
    let evidencePictureNames: [String]
    
    /// Ответ.
    public let answer: Answer
    
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
    
    func evidencePictureNameURLs(bundleID: String) -> [URL] {
        evidencePictureNames.compactMap {
            TasksBundleMap
                .extraEvidenceDirectoryURL(id: id, bundleID: bundleID)?
                .appendingPathComponent($0)
        }
    }
    
}
