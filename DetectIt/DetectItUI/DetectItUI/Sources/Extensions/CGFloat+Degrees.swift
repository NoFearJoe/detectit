//
//  CGFloat+Degrees.swift
//  DetectItUI
//
//  Created by Илья Харабет on 28/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import CoreGraphics

public extension CGFloat {
    
    var degrees: CGFloat {
        180 * self / .pi
    }
    
    var radians: CGFloat {
        self * .pi / 180
    }
    
}
