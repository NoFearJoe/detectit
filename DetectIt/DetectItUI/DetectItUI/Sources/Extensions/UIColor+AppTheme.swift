//
//  UIColor+AppTheme.swift
//  DetectItUI
//
//  Created by Илья Харабет on 28/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

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
