//
//  CGFloat+layoutInsets.swift
//  DetectItUI
//
//  Created by Илья Харабет on 23/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension CGFloat {
    
    static var hInset: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIScreen.main.bounds.width * 0.1
        } else {
            return 20
        }
    }
    
}
