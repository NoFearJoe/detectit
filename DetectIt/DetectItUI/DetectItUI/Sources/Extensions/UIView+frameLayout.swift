//
//  UIView+frameLayout.swift
//  DetectItUI
//
//  Created by Илья Харабет on 21/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public extension UIView {
    
    func calculateFrame(container: UIView, onChangeContainerBounds: @escaping (CGRect) -> CGRect) {
        translatesAutoresizingMaskIntoConstraints = true
        
        containerBoundsObservation = container.observe(\UIView.bounds, options: [.initial, .new]) { [weak self] container, change in
            guard let bounds = change.newValue else { return }
            
            self?.frame = onChangeContainerBounds(bounds)
        }
    }
    
    private struct AssociatedKeys {
        static var container = "containerBoundsObservation"
    }
    
    private var containerBoundsObservation: NSKeyValueObservation? {
        get {
            guard let observation = objc_getAssociatedObject(self, &AssociatedKeys.container) as? NSKeyValueObservation else {
                return nil
            }
            
            return observation
        }
        set {
            guard let newValue = newValue else { return }
            
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.container,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
}

public extension CGRect {
    
    static func centered(in rect: CGRect, size: CGSize) -> CGRect {
        CGRect(x: (rect.width / 2) - (size.width / 2), y: (rect.height / 2) - (size.height / 2), width: size.width, height: size.height)
    }
    
}
