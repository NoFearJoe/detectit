//
//  ProfileTask+Attachment.swift
//  DetectItCore
//
//  Created by Илья Харабет on 25/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public extension ProfileTask {
    
    /// Приложение к делу.
    /// Например, фотография карты с местами преступлений или аудиозапись интервью со свидетелем.
    struct Attachment: Codable {
        
        /// Подпись к приложению.
        public let title: String
        
        /// Название изображения.
        public let pictureName: String?
        
        /// Название аудиофайла.
        public let audioFileName: String?
        
    }
    
}

public extension ProfileTask.Attachment {
    
    enum Kind {
        case picture, audio
    }
    
    var kind: Kind {
        if audioFileName != nil {
            return .audio
        } else {
            return .picture
        }
    }
    
}
