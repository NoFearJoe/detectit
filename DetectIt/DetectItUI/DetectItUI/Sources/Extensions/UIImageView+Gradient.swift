//
//  UIImageView+Gradient.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public enum Fill {
    case color(UIColor)
    case gradient(startColor: UIColor, endColor: UIColor, startPosition: CGPoint, endPosition: CGPoint)
}

extension Fill: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.color(lhsColor), .color(rhsColor)):
            return lhsColor == rhsColor
        case let (.gradient(lhsStartColor, lhsEndColor, _, _), .gradient(rhsStartColor, rhsEndColor, _, _)):
            return lhsStartColor == rhsStartColor && lhsEndColor == rhsEndColor
        default:
            return false
        }
    }
    
}

public extension UIImage {
    
    static func gradient(size: CGSize,
                         startColor: UIColor,
                         endColor: UIColor,
                         startPoint: CGPoint,
                         endPoint: CGPoint) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { ctx in
            let gradient = CAGradientLayer()
            gradient.bounds = ctx.format.bounds
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
            gradient.colors = [startColor.cgColor, endColor.cgColor]
            gradient.locations = [0, 1]
            
            gradient.render(in: ctx.cgContext)
        }
    }
    
}
