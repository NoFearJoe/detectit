//
//  String+Localization.swift
//  DetectItCore
//
//  Created by Илья Харабет on 29/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public extension String {
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
}
