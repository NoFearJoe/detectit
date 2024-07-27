import SwiftUI

public extension Color {
    static let darkBackground = Color(white: 0.1)
    static let cardBackground = Color(white: 0.1)
    
    static let primaryText = Color(white: 0.92)
    static let secondaryText = Color(white: 0.7)
    static let headlineText = Color(red: 0.95, green: 0.95, blue: 0)
    
    static let systemBackground = Color(uiColor: .systemBackground)
}

public extension UIColor {
    
    // MARK: - Grounds
            
    static let darkBackground = UIColor(white: 0.1, alpha: 1)
    
    // MARK: - Text
    
    static let softWhite = UIColor(white: 0.95, alpha: 1)
    
    static func score(value: Int?, max: Int, defaultColor: UIColor = .lightGray) -> UIColor {
        guard let value = value else {
            return .lightGray
        }
        
        switch Float(value) / Float(max) {
        case ..<(0.4):
            return .red
        case (0.4)..<0.75:
            return .orange
        default:
            return .green
        }
    }
    
}
