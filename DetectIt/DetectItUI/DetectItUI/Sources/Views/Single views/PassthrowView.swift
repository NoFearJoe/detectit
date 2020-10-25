//
//  PassthrowView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 25.10.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

open class PassthrowView: UIView {

    open var shouldPassTouches = true
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard shouldPassTouches else { return true }
        return pointInside(point, inside: subviews, with: event)
    }
    
    fileprivate func pointInside(_ point: CGPoint,
                                 inside subviews: [UIView],
                                 with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview is PassthrowView {
                return pointInside(
                    convert(point, to: subview),
                    inside: subview.subviews,
                    with: event
                )
            } else if subview is UIControl {
                return subview.point(inside: point, with: event)
            } else if let stackView = subview as? UIStackView {
                return pointInside(
                    convert(point, to: stackView),
                    inside: stackView.arrangedSubviews,
                    with: event
                )
            } else {
                guard
                    !subview.isHidden,
                    subview.alpha != 0,
                    subview.isUserInteractionEnabled,
                    subview.point(inside: convert(point, to: subview), with: event)
                else {
                    continue
                }
                
                return true
            }
        }
        
        return false
    }

}
