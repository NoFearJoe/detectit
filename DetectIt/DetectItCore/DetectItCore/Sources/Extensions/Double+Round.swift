//
//  Double+Round.swift
//  DetectItCore
//
//  Created by Илья Харабет on 24/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public extension Double {
    
    func rounded(precision: Int) -> Double {
        let precision: Double = Double(10 * precision)
        return Foundation.round(precision * self) / precision
    }
    
}
