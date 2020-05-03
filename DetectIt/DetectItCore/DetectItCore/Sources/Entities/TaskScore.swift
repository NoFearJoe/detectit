//
//  TaskScore.swift
//  DetectItCore
//
//  Created by Илья Харабет on 05/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public struct TaskScore {
    
    private static let storage = UserDefaults.standard
    
    // MARK: - Get score
    
    public static func get(bundleID: String) -> Int? {
        storage.dictionaryRepresentation()
            .filter { $0.key.contains(bundleID) }
            .reduce(0, { $0 + ($1.value as? Int ?? 0) })
    }
    
    public static func get(id: String, taskKind: TaskKind, bundleID: String?) -> Int? {
        storage.object(
            forKey: makeKey(
                for: id,
                taskKind: taskKind,
                bundleID: bundleID
            )
        ) as? Int
    }
    
    // MARK: - Set score
    
    public static func set(value: Int, id: String, taskKind: TaskKind, bundleID: String?) {
        storage.set(
            value,
            forKey: makeKey(
                for: id,
                taskKind: taskKind,
                bundleID: bundleID
            )
        )
    }
    
    // MARK: - Utils
    
    public static func clear() {
        storage.dictionaryRepresentation().forEach { key, value in
            guard key.hasPrefix(keyPrefix) else { return }
            
            storage.removeObject(forKey: key)
        }
    }
    
    private static let keyPrefix = "task_score"
    
    private static func makeKey(for id: String, taskKind: TaskKind, bundleID: String?) -> String {
        if let bundleID = bundleID {
            return "\(keyPrefix)_\(bundleID)_\(taskKind)_\(id)"
        } else {
            return "\(keyPrefix)_\(taskKind)_\(id)"
        }
    }
    
}

public struct TaskAnswer {
    
    private static let storage = UserDefaults.standard
    
    // MARK: Cipher
        
    public static func get(decoderTaskID id: String, bundleID: String?) -> String? {
        storage.object(forKey: makeKey(for: id, taskKind: .cipher, bundleID: bundleID)) as? String
    }
    
    public static func set(answer: String, decoderTaskID id: String, bundleID: String?) {
        storage.set(answer, forKey: makeKey(for: id, taskKind: .cipher, bundleID: bundleID))
    }
    
    // MARK: Profile
    
    public enum ProfileAnswer: Codable {
        case string(String)
        case int(Int)
        case bool(Bool)
        
        public var string: String? {
            guard case .string(let string) = self else { return nil }
            return string
        }
        
        public var int: Int? {
            guard case .int(let int) = self else { return nil }
            return int
        }
        
        public var bool: Bool? {
            guard case .bool(let bool) = self else { return nil }
            return bool
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if let string = try? container.decode(String.self) {
                self = .string(string)
            } else if let int = try? container.decode(Int.self) {
                self = .int(int)
            } else if let bool = try? container.decode(Bool.self) {
                self = .bool(bool)
            } else {
                preconditionFailure()
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case let .string(value):
                try container.encode(value)
            case let .int(value):
                try container.encode(value)
            case let .bool(value):
                try container.encode(value)
            }
        }
        
    }
    
    public struct ProfileTaskAnswer: Codable {
        public let questionID: String
        public let answer: ProfileAnswer
        
        public init(questingID: String, answer: ProfileAnswer) {
            self.questionID = questingID
            self.answer = answer
        }
    }
    
    public static func get(profileTaskID id: String, bundleID: String?) -> [ProfileTaskAnswer]? {
        get(id: id, taskKind: .profile, bundleID: bundleID)
    }
    
    public static func set(answers: [ProfileTaskAnswer], profileTaskID id: String, bundleID: String?) {
        set(value: answers, id: id, taskKind: .profile, bundleID: bundleID)
    }
    
    // MARK: Quest
    
    public struct QuestTaskAnswer: Codable {
        let chapterIDs: [String]
        let endingID: String
        
        public init(chapterIDs: [String], endingID: String) {
            self.chapterIDs = chapterIDs
            self.endingID = endingID
        }
    }
    
    public static func get(questTaskID id: String, bundleID: String?) -> QuestTaskAnswer? {
        get(id: id, taskKind: .quest, bundleID: bundleID)
    }
    
    public static func set(answer: QuestTaskAnswer, questTaskID id: String, bundleID: String?) {
        set(value: answer, id: id, taskKind: .quest, bundleID: bundleID)
    }
    
    // MARK: Utils
    
    public static func clear() {
        storage.dictionaryRepresentation().forEach { key, value in
            guard key.hasPrefix(keyPrefix) else { return }
            
            storage.removeObject(forKey: key)
        }
    }
    
    private static func get<T: Decodable>(id: String, taskKind: TaskKind, bundleID: String?) -> T? {
        storage.decodable(forKey: makeKey(for: id, taskKind: taskKind, bundleID: bundleID))
    }
    
    private static func set<T: Encodable>(value: T, id: String, taskKind: TaskKind, bundleID: String?) {
        storage.setEncodable(value, forKey: makeKey(for: id, taskKind: taskKind, bundleID: bundleID))
    }
    
    private static let keyPrefix = "task_answer"
    
    private static func makeKey(for id: String, taskKind: TaskKind, bundleID: String?) -> String {
        if let bundleID = bundleID {
            return "\(keyPrefix)_\(bundleID)_\(taskKind)_\(id)"
        } else {
            return "\(keyPrefix)_\(taskKind)_\(id)"
        }
    }
    
}

private extension UserDefaults {
    
    func setEncodable<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }
        
        set(data, forKey: key)
    }
    
    func decodable<T: Decodable>(forKey key: String) -> T? {
        guard let data = self.object(forKey: key) as? Data else { return nil }
        
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
}
