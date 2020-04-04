//
//  UIColor+Overlay.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIColor {
    
    func addOverlay(color: UIColor) -> UIColor {
        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0
        
        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0
        
        getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        color.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)
        
        let red = fgA * fgR + (1 - fgA) * bgR
        let green = fgA * fgG + (1 - fgA) * bgG
        let blue = fgA * fgB + (1 - fgA) * bgB
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
}
