//
//  UIView+Shadow.swift
//  DetectItUI
//
//  Created by Илья Харабет on 29/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

// MARK: - Shadow

public extension UIView {
    
    func configureShadow(radius: CGFloat, opacity: Float, color: UIColor = .black, offset: CGSize = .zero) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
    }
    
}

// MARK: - Rounded corners

public extension UIView {
    
    @discardableResult
    func roundCorners(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let shape = CAShapeLayer()
        
        let cornerRadiiSize = CGSize(width: radius, height: radius)
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: cornerRadiiSize)
        
        shape.path = path.cgPath
        layer.mask = shape
        layer.masksToBounds = true
        
        return shape
    }
    
}

// MARK: - Layout

public extension UIView {
    
    func pin(to view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right),
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)
        ])
    }
    
}
