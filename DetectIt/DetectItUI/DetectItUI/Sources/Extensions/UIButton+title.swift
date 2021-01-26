//
//  UIButton+title.swift
//  DetectItUI
//
//  Created by Илья Харабет on 26.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

public extension UIButton {
    
    var title: String {
        title(for: .normal) ?? ""
    }
    
}
