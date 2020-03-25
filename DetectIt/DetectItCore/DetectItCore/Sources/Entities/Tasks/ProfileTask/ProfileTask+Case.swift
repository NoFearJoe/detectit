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
        
        /// Картинка для случая (опционально).
        public let pictureName: String?
        
    }
    
}

// MARK: - Resource accessing

public extension ProfileTask {
    
    func casePictureURL(case: Case, bundleID: String) -> URL? {
        `case`.pictureName.flatMap {
            TasksBundleMap
                .profileDirectoryURL(id: id, bundleID: bundleID)?
                .appendingPathComponent($0)
        }
    }
    
}
