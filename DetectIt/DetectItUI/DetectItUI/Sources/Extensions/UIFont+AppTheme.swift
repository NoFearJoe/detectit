//
//  UIFont+AppTheme.swift
//  DetectItUI
//
//  Created by Илья Харабет on 28/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIFont {
    
    static func text(_ size: CGFloat) -> UIFont {
        registerCustomFonts()
        
        return UIFont(name: "Arial Curive", size: size)!
    }
    
    static func title(_ size: CGFloat) -> UIFont {
        registerCustomFonts()
        
        return UIFont(name: "XBAND Rough Cyrillic AA", size: size)!
    }
    
}

private extension UIFont {
    
    static var isCustomFontsRegistered = false
    
    static func registerCustomFonts() {
        guard
            !isCustomFontsRegistered,
            let roughFontURL = Bundle(for: BundleID.self).url(forResource: "Rough", withExtension: "ttf") as CFURL?,
            let arialCuriveFontURL = Bundle(for: BundleID.self).url(forResource: "Arial Curive", withExtension: "otf") as CFURL?,
            let detectiveRegularFontURL = Bundle(for: BundleID.self).url(forResource: "Detective", withExtension: "ttf") as CFURL?,
            let detectiveBoldFontURL = Bundle(for: BundleID.self).url(forResource: "Detective Bold", withExtension: "ttf") as CFURL?
        else {
            return
        }
        
        CTFontManagerRegisterFontsForURL(roughFontURL, .process, nil)
        CTFontManagerRegisterFontsForURL(arialCuriveFontURL, .process, nil)
        CTFontManagerRegisterFontsForURL(detectiveRegularFontURL, .process, nil)
        CTFontManagerRegisterFontsForURL(detectiveBoldFontURL, .process, nil)
                
        isCustomFontsRegistered = true
    }
    
    final class BundleID {}
    
}
