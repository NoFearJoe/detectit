import SwiftUI

public extension Font {
    
    /// Bold 40
    static let heading0 = Font.bold(40)
    
    /// Bold 32
    static let heading1 = Font.bold(32)
    
    /// Bold 28
    static let heading2 = Font.bold(28)
    
    /// Bold 24
    static let heading3 = Font.bold(24)
    
    /// Bold 20
    static let heading4 = Font.bold(20)
    
    /// Regular 20
    static let text1 = Font.regular(20)
    
    /// Regular 18
    static let text2 = Font.regular(18)
    
    /// Bold 18
    static let text2Bold = Font.bold(18)
    
    /// Regular 16
    static let text3 = Font.regular(16)
    
    /// Regular 14
    static let text4 = Font.regular(14)
    
    /// Bold 14
    static let text4Bold = Font.bold(14)
    
    /// Regular 12
    static let text5 = Font.regular(12)
    
    /// Bold 44
    static let score1 = Font.bold(44)
    
    /// Bold 16
    static let score2 = Font.bold(16)
    
    /// Bold 14
    static let score3 = Font.bold(14)
    
}

private extension Font {
    
    static func regular(_ size: CGFloat) -> Font {
        .custom("AmericanTypewriter", fixedSize: size)
    }
    
    static func bold(_ size: CGFloat) -> Font {
        .custom("AmericanTypewriter-Bold", fixedSize: size)
    }
    
}

