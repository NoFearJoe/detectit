//
//  GradientView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 21/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class GradientView: UIView {
    
    public var startColor: UIColor = .black {
        didSet { updateColors() }
    }
    public var endColor: UIColor = UIColor.black.withAlphaComponent(0) {
        didSet { updateColors() }
    }
    public var startLocation: CGFloat = 0 {
        didSet { updateLocations() }
    }
    public var endLocation: CGFloat = 1 {
        didSet { updateLocations() }
    }
    
    public var startPoint: CGPoint = .zero {
        didSet {
            gradientLayer.startPoint = startPoint
        }
    }
    public var endPoint: CGPoint = CGPoint(x: 0, y: 1) {
        didSet {
            gradientLayer.endPoint = endPoint
        }
    }
    
    public var gradientType: CAGradientLayerType = .axial {
        didSet {
            gradientLayer.type = gradientType
        }
    }
    
    public override class var layerClass: AnyClass {
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateLocations()
    }
}

