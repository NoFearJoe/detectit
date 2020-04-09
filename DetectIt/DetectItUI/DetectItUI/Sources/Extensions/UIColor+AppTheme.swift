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
    
    static let paper = UIColor(red: 250/255, green: 250/255, blue: 240/255, alpha: 1)
    
    static let photo = UIColor(red: 232/255, green: 232/255, blue: 225/255, alpha: 1)
    
    // MARK: - Text
    
    static let mainText = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
    
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
