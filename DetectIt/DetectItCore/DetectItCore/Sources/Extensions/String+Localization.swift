import Foundation

public extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(_ args: CVarArg...) -> String {
        let string = NSLocalizedString(self, comment: "")
        
        return String(format: string, arguments: args)
    }
}
