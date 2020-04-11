//
//  String+AttributedString.swift
//  DetectItUI
//
//  Created by Илья Харабет on 11/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension String {
    
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
    
}
