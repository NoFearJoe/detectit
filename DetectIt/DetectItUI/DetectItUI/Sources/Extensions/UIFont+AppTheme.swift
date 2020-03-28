//
//  UIFont+AppTheme.swift
//  DetectItUI
//
//  Created by Илья Харабет on 28/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIFont {
    
    static func regular(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: size, weight: .regular)
    }
    
    static func semibold(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }
    
    static func bold(_ size: CGFloat) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }
    
}
