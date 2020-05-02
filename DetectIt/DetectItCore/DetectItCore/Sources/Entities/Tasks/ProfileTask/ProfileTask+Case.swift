//
//  ProfileTask+Case.swift
//  DetectItCore
//
//  Created by Илья Харабет on 25/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public extension ProfileTask {
    
    /// Случай. Случаем может быть описание событий за какой-то промежуток времени.
    struct Case: Codable {
        
        /// Идентификатор случая.
        public let id: String
        
        /// Заголовок.
        public let title: String
        
        /// Текст случая.
        public let text: String
        
        /// Фото улики (опционально).
        public let evidencePicture: EvidencePicture?
        
    }
    
}

public extension ProfileTask.Case {
    
    /// Фото улики.
    struct EvidencePicture: Codable {
        
        /// Подпись к приложению.
        public let title: String
        
        /// Название изображения.
        public let pictureName: String
        
    }
    
}
