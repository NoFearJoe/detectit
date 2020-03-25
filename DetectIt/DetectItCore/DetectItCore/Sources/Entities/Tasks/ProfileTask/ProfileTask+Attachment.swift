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
        
        /// Идентификатор приложения.
        public let id: String
        
        /// Название изображения.
        let pictureName: String?
        
        /// Название аудиофайла.
        let audioFileName: String?
        
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

// MARK: - Resource accessing

public extension ProfileTask {
    
    func attachmentURL(attachment: Attachment, bundleID: String) -> URL? {
        switch attachment.kind {
        case .audio:
            return attachment.audioFileName.flatMap {
                TasksBundleMap
                    .profileDirectoryURL(id: id, bundleID: bundleID)?
                    .appendingPathComponent($0)
            }
        case .picture:
            return attachment.pictureName.flatMap {
                TasksBundleMap
                    .profileDirectoryURL(id: id, bundleID: bundleID)?
                    .appendingPathComponent($0)
            }
        }
    }
    
}
