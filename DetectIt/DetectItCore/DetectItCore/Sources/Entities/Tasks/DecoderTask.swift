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
