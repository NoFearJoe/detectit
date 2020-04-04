//
//  TasksBundle.swift
//  DetectItCore
//
//  Created by Илья Харабет on 24/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public struct TasksBundle {
    
    public let id: String
    public let audiorecordTasks: [AudioRecordTask]
    public let decoderTasks: [DecoderTask]
    public let extraEvidenceTasks: [ExtraEvidenceTask]
    public let profileTasks: [ProfileTask]
    public let questTasks: [QuestTask]
    
    public static func load(bundleID: String, completion: @escaping (TasksBundle?) -> Void) {
        guard let map = try? TasksBundleMap(bundleID: bundleID) else {
            return completion(nil)
        }
        
        DispatchQueue.global(qos: .utility).async {
            let bundle = TasksBundle(
                id: bundleID,
                audiorecordTasks: Self.decode(AudioRecordTask.self, paths: map.audiorecords),
                decoderTasks: Self.decode(DecoderTask.self, paths: map.ciphers),
                extraEvidenceTasks: Self.decode(ExtraEvidenceTask.self, paths: map.extraEvidences),
                profileTasks: Self.decode(ProfileTask.self, paths: map.profiles),
                questTasks: Self.decode(QuestTask.self, paths: map.quests)
            )
            
            DispatchQueue.main.async {
                completion(bundle)
            }
        }
    }
    
    private static func decode<T: Decodable>(_ type: T.Type, paths: [URL]) -> [T] {
        paths.compactMap {
            let urlToTaskFile = $0.appendingPathComponent("task").appendingPathExtension("json")
            guard let data = FileManager.default.contents(atPath: urlToTaskFile.path) else { return nil }
            return try? JSONDecoder().decode(type, from: data)
        }
    }
    
}
