//
//  String+AttributedString.swift
//  DetectItUI
//
//  Created by Илья Харабет on 11/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import SwiftUI

public extension String {
    
    func attributed() -> NSAttributedString {
        NSAttributedString(string: self)
    }
    
    func readableAttributedText(font: UIFont, color: UIColor = .softWhite) -> NSAttributedString {
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
                NSAttributedString.Key.strikethroughStyle: 4,
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

extension String {
    public func readableAttributedText(font: Font, color: Color = .primaryText) -> AttributedString {
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 2
//        paragraphStyle.paragraphSpacing = 4
        
        var attributedString = AttributedString(self)
        
        attributedString.font = font
        attributedString.foregroundColor = color
        attributedString.kern = 0.25
//        attributedString.mergeAttributes(.init([.paragraphStyle: paragraphStyle]))
        
        return replacingMarkdown(in: attributedString, font: font)
    }
    
    func replacingMarkdown(in attributedString: AttributedString, font: Font) -> AttributedString {
        let textRegexp: (String) -> String = { #"[\w\s\d.,:""''!@$%^&?-_+=`(){}"# + $0 + "]+" }
        let markdownPlaceholders: [String: [NSAttributedString.Key: Any]] = [
            "##\(textRegexp("~*"))##": [.font: font.bold()],
            "~~\(textRegexp("#*"))~~": [.font: font.italic()],
            "\\*\\*\(textRegexp("#~"))\\*\\*": [.foregroundColor: Color.yellow]
        ]
        
        var resultString = self
        var result = attributedString
        
        markdownPlaceholders.forEach { placeholder, attributes in
            let regexp = try! NSRegularExpression(pattern: placeholder, options: .caseInsensitive)
            let matches = regexp.matches(in: resultString, options: [], range: NSRange(location: 0, length: resultString.count))
            matches.reversed().forEach { match in
                let openingBracketNSRange = NSRange(location: match.range.location, length: 2)
                let closingBracketNSRange = NSRange(location: match.range.upperBound - 2, length: 2)
                                
                guard
                    let range = match.range.range(attributedString: result),
                    let openingBracketRange = openingBracketNSRange.range(attributedString: result),
                    let closingBracketRange = closingBracketNSRange.range(attributedString: result)
                else { return }
                
                attributes.forEach {
                    switch $0.key {
                    case .font:
                        result[range].font = $0.value as? Font
                    case .foregroundColor:
                        result[range].foregroundColor = $0.value as? Color
                    default:
                        return
                    }
                }
                result.removeSubrange(closingBracketRange)
                result.removeSubrange(openingBracketRange)
                resultString.removeSubrange(closingBracketNSRange.range(string: resultString))
                resultString.removeSubrange(openingBracketNSRange.range(string: resultString))
            }
        }
                        
        return result
    }
}

private extension NSRange {
    func range(attributedString: AttributedString) -> Range<AttributedString.Index>? {
        guard
            attributedString.characters.count > lowerBound,
            attributedString.characters.count >= upperBound
        else { return nil }
        
        let lowerBound = attributedString.characters.index(
            attributedString.startIndex,
            offsetBy: lowerBound
        )
        let upperBound = attributedString.characters.index(
            attributedString.startIndex,
            offsetBy: upperBound
        )
        
        return lowerBound..<upperBound
    }
    
    func range(string: String) -> Range<String.Index> {
        let lb = string.index(string.startIndex, offsetBy: lowerBound)
        let ub = string.index(string.startIndex, offsetBy: upperBound)
        
        return lb..<ub
    }
}
