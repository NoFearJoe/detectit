import Foundation

public struct TaskScore {
    
    #if RELEASE
    private static let storage: Storage = Keychain()
    #else
    private static let storage: Storage = UserDefaults.standard
    #endif
    
    public static func get(id: String, taskKind: TaskKind) -> Int? {
        storage.get(
            key: makeKey(
                for: id,
                taskKind: taskKind
            )
        )
    }
    
    public static func set(value: Int, id: String, taskKind: TaskKind) {
        storage.save(
            value,
            key: makeKey(
                for: id,
                taskKind: taskKind
            )
        )
    }
    
    // MARK: - Utils
    
    public static func clear() {
        #if DEBUG
        let storage = self.storage as! UserDefaults
        storage.dictionaryRepresentation().forEach { key, value in
            guard key.hasPrefix(keyPrefix) else { return }
            
            storage.removeObject(forKey: key)
        }
        #endif
    }
    
    private static let keyPrefix = "task_score"
    
    private static func makeKey(for id: String, taskKind: TaskKind) -> String {
        "\(keyPrefix)_\(taskKind)_\(id)"
    }
    
}

public struct TaskAnswer {
    
    #if RELEASE
    private static let storage: Storage = Keychain()
    #else
    private static let storage: Storage = UserDefaults.standard
    #endif
    
    // MARK: Cipher
        
    public static func get(decoderTaskID id: String) -> String? {
        storage.get(key: makeKey(for: id, taskKind: .cipher))
    }
    
    public static func set(answer: String, decoderTaskID id: String) {
        storage.save(answer, key: makeKey(for: id, taskKind: .cipher))
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
    
    public static func get(profileTaskID id: String) -> [ProfileTaskAnswer]? {
        get(id: id, taskKind: .profile)
    }
    
    public static func set(answers: [ProfileTaskAnswer], profileTaskID id: String) {
        set(value: answers, id: id, taskKind: .profile)
    }
    
    // MARK: Blitz
    
    public typealias BlitzTaskAnswer = ProfileTaskAnswer
    
    public static func get(blitzTaskID id: String) -> BlitzTaskAnswer? {
        get(id: id, taskKind: .profile)
    }
    
    public static func set(answer: BlitzTaskAnswer, blitzTaskID id: String) {
        set(value: answer, id: id, taskKind: .profile)
    }
    
    // MARK: Quest
    
    public struct QuestTaskAnswer: Codable {
        
        public struct Route: Codable {
            public let fromChapter: String
            public let toChapter: String
            
            public init(fromChapter: String, toChapter: String) {
                self.fromChapter = fromChapter
                self.toChapter = toChapter
            }
        }
        
        public var routes: [Route]
        public var ending: Route?
        
        public init(routes: [Route], ending: Route?) {
            self.routes = routes
            self.ending = ending
        }
    }
    
    public static func get(questTaskID id: String) -> QuestTaskAnswer? {
        get(id: id, taskKind: .quest)
    }
    
    public static func set(answer: QuestTaskAnswer, questTaskID id: String) {
        set(value: answer, id: id, taskKind: .quest)
    }
    
    // MARK: Utils
    
    public static func clear() {
        #if DEBUG
        let storage = self.storage as! UserDefaults
        storage.dictionaryRepresentation().forEach { key, value in
            guard key.hasPrefix(keyPrefix) else { return }
            
            storage.removeObject(forKey: key)
        }
        #endif
    }
    
    private static func get<T: Decodable>(id: String, taskKind: TaskKind) -> T? {
        storage.getDecodable(key: makeKey(for: id, taskKind: taskKind))
    }
    
    private static func set<T: Encodable>(value: T, id: String, taskKind: TaskKind) {
        storage.saveEncodable(value, key: makeKey(for: id, taskKind: taskKind))
    }
    
    private static let keyPrefix = "task_answer"
    
    private static func makeKey(for id: String, taskKind: TaskKind) -> String {
        "\(keyPrefix)_\(taskKind)_\(id)"
    }
    
}
