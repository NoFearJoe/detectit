//
//  TasksBundleMap.swift
//  DetectItCore
//
//  Created by Илья Харабет on 24/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

/// Предоставляет функционал для получения пути к директориям с заданиями.
struct TasksBundleMap {
            
    let audiorecords: [URL]
    let ciphers: [URL]
    let extraEvidences: [URL]
    let profiles: [URL]
    let quests: [URL]
    
    /// Инициализирует объект с идентификатором набора заданий.
    init(bundleID: String) throws {
        let bundleDirectory = "\(bundleID).tasksbundle"
        
        guard let baseURL = Self.baseURL(bundleDirectory: bundleDirectory) else {
            throw Error.bundleMapFileIsNotExists
        }
        
        audiorecords = Self.tasksPaths(directory: Static.audiorecords, baseURL: baseURL)
        ciphers = Self.tasksPaths(directory: Static.ciphers, baseURL: baseURL)
        extraEvidences = Self.tasksPaths(directory: Static.extraEvidences, baseURL: baseURL)
        profiles = Self.tasksPaths(directory: Static.extraEvidences, baseURL: baseURL)
        quests = Self.tasksPaths(directory: Static.quests, baseURL: baseURL)
    }
    
}

extension TasksBundleMap {
    
    enum Error: Swift.Error {
        case bundleMapFileIsNotExists
    }
    
}
    
private extension TasksBundleMap {
 
    static func baseURL(bundleDirectory: String) -> URL? {
        (URL(string: Static.root)?
            .appendingPathComponent(bundleDirectory))
            .flatMap {
                Bundle.main.url(forResource: $0.path, withExtension: nil)
            }
    }
    
    static func tasksPaths(directory: String, baseURL: URL) -> [URL] {
        (try? FileManager.default.contentsOfDirectory(
            at: baseURL.appendingPathComponent(directory),
            includingPropertiesForKeys: nil
        )) ?? []
    }
    
}

private extension TasksBundleMap {
    
    private struct Static {
        static let root = "TaskBundles"
                
        static let audiorecords = "audiorecords"
        static let ciphers = "ciphers"
        static let extraEvidences = "extraevidences"
        static let profiles = "profiles"
        static let quests = "quests"
    }
    
}
