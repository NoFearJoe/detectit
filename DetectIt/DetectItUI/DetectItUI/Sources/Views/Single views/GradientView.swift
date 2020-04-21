//
//  GradientView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 21/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

final class GradientView: UIView {
    
    var startColor: UIColor = .black {
        didSet { updateColors() }
    }
    var endColor: UIColor = UIColor.black.withAlphaComponent(0) {
        didSet { updateColors() }
    }
    var startLocation: CGFloat = 0 {
        didSet { updateLocations() }
    }
    var endLocation: CGFloat = 1 {
        didSet { updateLocations() }
    }
    
    var startPoint: CGPoint = .zero {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    var endPoint: CGPoint = CGPoint(x: 0, y: 1) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLocations()
    }
}

