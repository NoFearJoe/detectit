import Foundation

public protocol Task {
    var id: String { get }
    var title: String { get }
    var kind: TaskKind { get }
    var taskDifficulty: TaskDifficulty { get }
}
