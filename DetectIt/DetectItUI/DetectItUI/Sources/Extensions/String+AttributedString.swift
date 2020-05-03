//
//  String+AttributedString.swift
//  DetectItUI
//
//  Created by Илья Харабет on 11/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension String {
    
    func attributed() -> NSAttributedString {
        NSAttributedString(string: self)
    }
    
    func readableAttributedText() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.paragraphSpacing = 4
        
        return NSAttributedString(
            string: self,
            attributes: [
                NSAttributedString.Key.kern: 0.25,
                NSAttributedString.Key.paragraphStyle: paragraphStyle
            ]
        )
    }
    
    func strikethroughAttributedString(color: UIColor) -> NSAttributedString {
        NSAttributedString(
            string: self,
            attributes: [
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.strikethroughColor: color
            ]
        )
    }
    
    func attributedTextWithShadow() -> NSAttributedString {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black
        shadow.shadowBlurRadius = 16
        
        return NSAttributedString(
            string: self,
            attributes: [
                NSAttributedString.Key.shadow: shadow
            ]
        )
    }
    
}
