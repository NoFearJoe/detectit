//
//  TasksBundleMap.swift
//  DetectItCore
//
//  Created by Илья Харабет on 24/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

/// Предоставляет функционал для получения пути к директориям с заданиями.
public struct TasksBundleMap {
    
    let info: URL
    let imageURL: URL
    let audiorecords: [URL]
    let ciphers: [URL]
    let extraEvidences: [URL]
    let profiles: [URL]
    let quests: [URL]
    
    /// Инициализирует объект с идентификатором набора заданий.
    init(bundleID: String) throws {
        let bundleDirectory = Self.makeBundleDirectory(id: bundleID)
        
        guard let baseURL = Self.baseURL(bundleDirectory: bundleDirectory) else {
            throw Error.bundleIsNotExists
        }
        
        guard let info = Self.bundleURL(bundleID: bundleID)?.appendingPathComponent("info.json") else {
            throw Error.infoFileIsNotExists
        }
        
        guard let imageURL = Self.bundleURL(bundleID: bundleID)?.appendingPathComponent("image.png") else {
            throw Error.imageFileIsNotExists
        }
        
        self.info = info
        self.imageURL = imageURL
        audiorecords = Self.tasksPaths(directory: Static.audiorecords, baseURL: baseURL)
        ciphers = Self.tasksPaths(directory: Static.ciphers, baseURL: baseURL)
        extraEvidences = Self.tasksPaths(directory: Static.extraEvidences, baseURL: baseURL)
        profiles = Self.tasksPaths(directory: Static.extraEvidences, baseURL: baseURL)
        quests = Self.tasksPaths(directory: Static.quests, baseURL: baseURL)
    }
    
    public static var taskBundlesRootURL: URL? {
        URL(string: Static.root).flatMap {
            Bundle.main.url(forResource: $0.path, withExtension: nil)
        }
    }
    
}

extension TasksBundleMap {
    
    enum Error: Swift.Error {
        case bundleIsNotExists
        case infoFileIsNotExists
        case imageFileIsNotExists
    }
    
}

extension TasksBundleMap {
    
    static func bundleURL(bundleID: String) -> URL? {
        baseURL(bundleDirectory: makeBundleDirectory(id: bundleID))
    }
    
    static func dictionariesDirectoryURL(bundleID: String) -> URL? {
        bundleURL(bundleID: bundleID)?
            .appendingPathComponent(Static.dictionaries)
    }
    
    static func audiorecordDirectoryURL(id: String, bundleID: String) -> URL? {
        taskDirectoryURL(bundleID: bundleID, directory: Static.audiorecords, taskID: id)
    }
    
    static func cipherDirectoryURL(id: String, bundleID: String) -> URL? {
        taskDirectoryURL(bundleID: bundleID, directory: Static.ciphers, taskID: id)
    }
    
    static func extraEvidenceDirectoryURL(id: String, bundleID: String) -> URL? {
        taskDirectoryURL(bundleID: bundleID, directory: Static.extraEvidences, taskID: id)
    }
    
    static func profileDirectoryURL(id: String, bundleID: String) -> URL? {
        taskDirectoryURL(bundleID: bundleID, directory: Static.profiles, taskID: id)
    }
    
    static func questDirectoryURL(id: String, bundleID: String) -> URL? {
        taskDirectoryURL(bundleID: bundleID, directory: Static.quests, taskID: id)
    }
    
    private static func taskDirectoryURL(bundleID: String, directory: String, taskID: String) -> URL? {
        bundleURL(bundleID: bundleID)?
            .appendingPathComponent(directory)
            .appendingPathComponent(taskID)
    }
    
}
    
private extension TasksBundleMap {
    
    static func makeBundleDirectory(id: String) -> String {
        "\(id)"
    }
 
    static func baseURL(bundleDirectory: String) -> URL? {
        taskBundlesRootURL?.appendingPathComponent(bundleDirectory)
    }
    
    static func tasksPaths(directory: String, baseURL: URL) -> [URL] {
        (try? FileManager.default.contentsOfDirectory(
            at: baseURL.appendingPathComponent(directory),
            includingPropertiesForKeys: nil
        )) ?? []
    }
    
}

private extension TasksBundleMap {
    
    struct Static {
        static let root = "TaskBundles"
        
        static let dictionaries = "dictionaries"
                
        static let audiorecords = "audiorecords"
        static let ciphers = "ciphers"
        static let extraEvidences = "extraevidences"
        static let profiles = "profiles"
        static let quests = "quests"
    }
    
}
