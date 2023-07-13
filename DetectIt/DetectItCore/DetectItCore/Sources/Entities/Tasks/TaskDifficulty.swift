import UIKit

public enum TaskDifficulty: Int {
    case easy = 1
    case normal = 2
    case hard = 3
    case nightmare = 5
    
    public init(rawValue: Int) {
        switch rawValue {
        case 2:
            self = .normal
        case 3:
            self = .hard
        case 5:
            self = .nightmare
        default:
            self = .easy
        }
    }
    
    public var localizedTitle: String {
        switch self {
        case .easy: return "task_difficulty_easy".localized
        case .normal: return "task_difficulty_normal".localized
        case .hard: return "task_difficulty_hard".localized
        case .nightmare: return "task_difficulty_nightmare".localized
        }
    }
    
    public var color: UIColor {
        switch self {
        case .easy: return .green
        case .normal: return .orange
        case .hard: return .red
        case .nightmare: return .magenta
        }
    }
}
