import Foundation

public struct Feed: Codable {
    public var items: [Item]
}

public extension Feed {
    
    struct Item: Codable, Hashable, Identifiable {
        public let id: String
        public let kind: Kind
        public let title: String
        public let subtitle: String?
        public let picture: String?
        public let difficulty: Int
        public let score: Int?
        public let maxScore: Int
        public let completed: Bool
        public let cipher: DecoderTask?
        public let profile: ProfileTask?
        public let blitz: BlitzTask?
        public let quest: QuestTask?
        
        public init(id: String, kind: Kind, title: String, subtitle: String?, picture: String?, difficulty: Int, score: Int?, maxScore: Int, completed: Bool, cipher: DecoderTask? = nil, profile: ProfileTask? = nil, blitz: BlitzTask? = nil, quest: QuestTask? = nil) {
            self.id = id
            self.kind = kind
            self.title = title
            self.subtitle = subtitle
            self.picture = picture
            self.difficulty = difficulty
            self.score = score
            self.maxScore = maxScore
            self.completed = completed
            self.cipher = cipher
            self.profile = profile
            self.blitz = blitz
            self.quest = quest
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

public extension Feed.Item {
    enum Kind: String, Codable {
        case cipher
        case profile
        case blitz
        case quest
    }
}
