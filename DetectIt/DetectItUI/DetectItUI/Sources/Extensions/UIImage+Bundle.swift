//
//  UIImage+Bundle.swift
//  DetectItUI
//
//  Created by Илья Харабет on 28/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func asset(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle(for: BundleID.self), compatibleWith: nil)
    }
    
}

private final class BundleID {}
