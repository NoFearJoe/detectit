//
//  UIView+Animations.swift
//  DetectItUI
//
//  Created by Илья Харабет on 03/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIView {
    
    func setHidden(_ hidden: Bool, duration: TimeInterval) {
        if duration > 0 {
            if isHidden && !hidden {
                alpha = 0
                isHidden = false
            }
            
            UIView.animate(withDuration: duration, animations: {
                self.alpha = hidden ? 0 : 1
            }) { _ in
                self.isHidden = hidden
            }
        } else {
            isHidden = hidden
        }
    }
    
}
