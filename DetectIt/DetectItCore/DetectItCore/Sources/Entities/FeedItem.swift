import Foundation

public struct FeedItem: Codable, Hashable {
    public let id: String
    public let kind: TaskKind
}
