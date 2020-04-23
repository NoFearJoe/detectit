//
//  SolidButton.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

open class SolidButton: UIButton, TouchAnimatable {
    
    // MARK: - Public variables
    
    /// The color which overlays the fill when button is in `highlighted` or `selected` state.
    public var overlayColor = UIColor.black.withAlphaComponent(0.05) {
        didSet {
            updateFill()
        }
    }
    
    /// The fill type of the button.
    public var fill: Fill = .color(.clear) {
        didSet {
            setFill(fill)
        }
    }
    
    public override var bounds: CGRect {
        didSet {
            updateFill()
        }
    }
    
    // MARK: - Private functions
    
    private func updateFill() {
        setFill(fill)
    }
    
    // MARK: - Override functions
    
    @available(*, unavailable, message: "You should use the `fill` property")
    public override final var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            super.backgroundColor = newValue
        }
    }
    
    @available(*, unavailable, message: "You should use the `fill` property")
    public override final func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        super.setBackgroundImage(image, for: state)
    }
    
    @available(*, unavailable, message: "You should use the `fill` property")
    public override final func setBackgroundImageClippedToBounds(_ image: UIImage?, for state: UIControl.State) {
        super.setBackgroundImageClippedToBounds(image, for: state)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                // TODO
            }
        }
    }
    
}

// MARK: Factories

public extension SolidButton {
    
    static func makePushButton() -> SolidButton {
        let button = SolidButton()
        
        button.clipsToBounds = true
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        button.titleLabel?.font = .score3
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        return button
    }
    
    static func closeButton() -> SolidButton {
        let button = SolidButton()
        
        button.layer.cornerRadius = 12
        button.fill = .color(.lightGray)
        button.tintColor = .darkGray
        button.setImage(UIImage.asset(named: "close"), for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return button
    }
    
    static func primaryButton() -> SolidButton {
        let button = SolidButton()
        
        button.layer.cornerRadius = 8
        button.fill = .color(.yellow)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .text2
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        return button
    }
    
    static func helpButton() -> SolidButton {
        let button = SolidButton()
        
        button.layer.cornerRadius = 12
        button.fill = .color(.clear)
        button.tintColor = .yellow
        button.setImage(UIImage.asset(named: "help"), for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return button
    }
    
}

// MARK: - Private extensions

// MARK: Fill

private extension SolidButton {
    
    func setFill(_ fill: Fill) {
        switch fill {
        case let .color(color):
            setBackgroundColor(color)
        case let .gradient(startColor, endColor, startPoint, endPoint):
            setBackgroundGradient(startColor: startColor,
                                  endColor: endColor,
                                  startPoint: startPoint,
                                  endPoint: endPoint)
        }
    }
    
    func setBackgroundColor(_ color: UIColor?) {
        guard let color = color, color != .clear else {
            super.setBackgroundImage(nil, for: .normal)
            super.setBackgroundImage(nil, for: .highlighted)
            super.setBackgroundImage(nil, for: .selected)
            return
        }
        
        let highlightedColor = color.addOverlay(color: overlayColor)
        
        super.setBackgroundImageClippedToBounds(UIImage.plain(color: color), for: .normal)
        super.setBackgroundImageClippedToBounds(UIImage.plain(color: highlightedColor), for: .highlighted)
        super.setBackgroundImageClippedToBounds(UIImage.plain(color: highlightedColor), for: [.selected, .highlighted])
    }
    
    func setBackgroundGradient(startColor: UIColor,
                               endColor: UIColor,
                               startPoint: CGPoint,
                               endPoint: CGPoint) {
        let imageForNormalState = UIImage.gradient(
            size: bounds.size,
            startColor: startColor,
            endColor: endColor,
            startPoint: startPoint,
            endPoint: endPoint
        )
        super.setBackgroundImageClippedToBounds(imageForNormalState, for: .normal)
        
        let highlightedStartColor = startColor.addOverlay(color: overlayColor)
        let highlightedEndColor = endColor.addOverlay(color: overlayColor)
        let imageForSelectedState = UIImage.gradient(size: bounds.size,
                                                     startColor: highlightedStartColor,
                                                     endColor: highlightedEndColor,
                                                     startPoint: startPoint,
                                                     endPoint: endPoint)
        
        super.setBackgroundImageClippedToBounds(imageForSelectedState, for: .highlighted)
        super.setBackgroundImageClippedToBounds(imageForSelectedState, for: [.selected, .highlighted])
    }
    
}

extension UIButton {
    
    @objc
    open func setBackgroundImageClippedToBounds(_ image: UIImage?, for state: UIControl.State) {
        guard !clipsToBounds && layer.cornerRadius != 0 else {
            return setBackgroundImage(image, for: state)
        }
        
        let roundedResizedImage = image?
            .resized(to: bounds.size, preserveAspectRatio: false)
            .rounded(radius: layer.cornerRadius)
        
        setBackgroundImage(roundedResizedImage, for: state)
    }
    
}
