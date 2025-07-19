//
//  CGPoint+Operators.swift
//  DetectItUI
//
//  Created by Илья Харабет on 11/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension CGPoint {
    
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func angle(start: CGPoint, end: CGPoint) -> CGFloat {
        let diff = end - start
        let degrees = atan2(diff.y, diff.x).degrees
        
        return degrees > 0 ? degrees : 360 + degrees
    }
    
}

public extension CGSize {
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func angle(start: CGSize, end: CGSize) -> CGFloat {
        let diff = end - start
        let degrees = atan2(diff.width, diff.height).degrees
        
        return degrees > 0 ? degrees : 360 + degrees
    }
}

public extension CGFloat {
    
    func rotate(degrees: CGFloat) -> CGFloat {
        if self >= degrees {
            return self - degrees
        } else {
            return (self + 360) - degrees
        }
    }
    
}
