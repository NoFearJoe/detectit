//
//  UIFont+AppTheme.swift
//  DetectItUI
//
//  Created by Илья Харабет on 28/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIFont {
    
    /// Bold 32
    static let heading1 = UIFont.bold(32)
    
    /// Bold 28
    static let heading2 = UIFont.bold(28)
    
    /// Bold 24
    static let heading3 = UIFont.bold(24)
    
    /// Bold 20
    static let heading4 = UIFont.bold(20)
    
    /// Regular 20
    static let text1 = UIFont.regular(20)
    
    /// Regular 18
    static let text2 = UIFont.regular(18)
    
    /// Regular 16
    static let text3 = UIFont.regular(16)
    
    /// Regular 14
    static let text4 = UIFont.regular(14)
    
    /// Regular 12
    static let text5 = UIFont.regular(12)
    
    /// Bold 44
    static let score1 = UIFont.bold(44)
    
    /// Bold 16
    static let score2 = UIFont.bold(16)
    
    /// Bold 14
    static let score3 = UIFont.bold(14)
    
}

private extension UIFont {
    
    static func regular(_ size: CGFloat) -> UIFont {
        UIFont(name: "AmericanTypewriter", size: size)!
    }
    
    static func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: "AmericanTypewriter-Bold", size: size)!
    }
    
}
