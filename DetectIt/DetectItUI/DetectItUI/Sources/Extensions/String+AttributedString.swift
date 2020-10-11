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
    
    func readableAttributedText(font: UIFont, color: UIColor = .white) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.paragraphSpacing = 4
        
        return NSMutableAttributedString(
            string: self,
            attributes: [
                .font: font,
                .kern: 0.25,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: color
            ]
        ).replacingMarkdown(font: font)
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

private extension NSMutableAttributedString {
    
    func replacingMarkdown(font: UIFont) -> NSAttributedString {
        let textRegexp: (String) -> String = { #"[\w\s\d.,:""''!@$%^&?-_+=`(){}"# + $0 + "]+" }
        let markdownPlaceholders: [String: [NSAttributedString.Key: Any]] = [
            "##\(textRegexp("~*"))##": [.font: font.bold()],
            "~~\(textRegexp("#*"))~~": [.font: font.italic()],
            "\\*\\*\(textRegexp("#~"))\\*\\*": [.foregroundColor: UIColor.yellow]
        ]
        
        markdownPlaceholders.forEach { placeholder, attributes in
            let regexp = try! NSRegularExpression(pattern: placeholder, options: .caseInsensitive)
            let matches = regexp.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
            matches.reversed().forEach { match in
                addAttributes(attributes, range: match.range)
                deleteCharacters(in: NSRange(location: match.range.upperBound - 2, length: 2))
                deleteCharacters(in: NSRange(location: match.range.location, length: 2))
            }
        }
        
        return self
    }
    
}
