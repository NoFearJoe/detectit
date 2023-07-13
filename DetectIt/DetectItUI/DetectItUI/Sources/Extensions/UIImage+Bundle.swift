//
//  UIImage+Bundle.swift
//  DetectItUI
//
//  Created by Илья Харабет on 28/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIImage {
    
    static func asset(named: String) -> UIImage? {
        return UIImage(named: named, in: .ui, compatibleWith: nil)
    }
    
}

private final class BundleID {}

public extension Bundle {
    static let ui = Bundle(for: BundleID.self)
}
