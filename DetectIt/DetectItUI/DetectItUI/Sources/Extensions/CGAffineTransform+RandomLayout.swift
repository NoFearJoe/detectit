//
//  CGAffineTransform+RandomLayout.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import CoreGraphics

public extension CGAffineTransform {
    
    static func randomLayout() -> CGAffineTransform {
        let angle = CGFloat.random(in: -1...1)
        let rotation = CGAffineTransform(rotationAngle: angle.radians)
        
        let translationX = CGFloat.random(in: -4...4)
        let translationY = CGFloat.random(in: -4...4)
        let translation = CGAffineTransform(translationX: translationX, y: translationY)
        
        return rotation.concatenating(translation)
    }
    
}
