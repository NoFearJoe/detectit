//
//  Double+SafeDivide.swift
//  DetectItCore
//
//  Created by Илья Харабет on 21.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Foundation

public extension Double {
    
    func safeDivide(by divider: Double) -> Double {
        guard divider != 0 else { return 0 }
        
        return self / divider
    }
    
}
