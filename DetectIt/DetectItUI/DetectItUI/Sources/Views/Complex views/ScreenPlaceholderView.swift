//
//  ScreenPlaceholderView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ScreenPlaceholderView: UIView {
    
    private let imageView = UIImageView(image: UIImage.asset(named: "ScreenPlaceholderIcon"))
    
    private let isInitiallyHidden: Bool
    
    public init(isInitiallyHidden: Bool) {
        self.isInitiallyHidden = isInitiallyHidden
        
        super.init(frame: .zero)
        
        setup()
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    public func setVisible(_ isVisible: Bool, animated: Bool) {
        if isVisible {
            alpha = 0
            isHidden = false
        }
        
        UIView.animate(
            withDuration: animated ? 0.5 : 0,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.alpha = isVisible ? 1 : 0
            }, completion: { _ in
                if !isVisible {
                    self.isHidden = true
                } else {
                    self.startShimmeringAnimation()
                }
            }
        )
    }
    
    private func setup() {
        backgroundColor = .black
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupViews() {
        addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.layer.opacity = isInitiallyHidden ? 0 : 1
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 96),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private var hasShimmeringAnimationStarted = false
    
    private func startShimmeringAnimation() {
        guard !hasShimmeringAnimationStarted else { return }
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.beginTime = isInitiallyHidden ? CACurrentMediaTime() + 0.5 : CACurrentMediaTime()
        animation.fromValue = isInitiallyHidden ? 0 : 1
        animation.toValue = isInitiallyHidden ? 1 : 0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.duration = 1
        imageView.layer.add(animation, forKey: "shimmering")
        
        hasShimmeringAnimationStarted = true
    }
    
}
