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
    
    let bundlemap = "bundlemap"
    
    let audiorecords = "audiorecords"
    let ciphers = "ciphers"
    let extraEvidences = "extraevidences"
    let profiles = "profiles"
    let quests = "quests"
    
    let directory: String
    
    /// Инициализирует объект с идентификатором набора заданий.
    public init(bundleID: String) {
        directory = "\(bundleID).tasksbundle"
    }
    
    // MARK: - Public
    
    /// Возвращает URL файла bundlemap, в котором хранятся списки заданий.
    public func bundleMapURL() -> URL {
        URL(
            fileURLWithPath: directory,
            isDirectory: true,
            relativeTo: baseURL
        )
        .appendingPathComponent(bundlemap)
        .appendingPathExtension("json")
    }
    
    /// Возвращает URL директории с "Аудиозаписью".
    public func audiorecordURL(id: String) -> URL {
        taskURL(id: id, directory: audiorecords)
    }
    
    /// Возвращает URL директории с "Шифром".
    public func cipherURL(id: String) -> URL {
        taskURL(id: id, directory: ciphers)
    }
    
    /// Возвращает URL директории с "Лишней уликой".
    public func extraEvidenceURL(id: String) -> URL {
        taskURL(id: id, directory: extraEvidences)
    }
    
    /// Возвращает URL директории с "Профайлом".
    public func profileURL(id: String) -> URL {
        taskURL(id: id, directory: profiles)
    }
    
    /// Возвращает URL директории с "Квестом".
    public func questURL(id: String) -> URL {
        taskURL(id: id, directory: quests)
    }
    
    // MARK: - Private
    
    private var baseURL: URL? {
        Bundle.main.url(
            forResource: directory,
            withExtension: nil
        )
    }
    
    private func taskURL(id: String, directory: String) -> URL {
        URL(
            fileURLWithPath: directory,
            isDirectory: true,
            relativeTo: baseURL
        )
        .appendingPathComponent(id)
    }
    
}
