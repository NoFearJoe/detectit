//
//  RatingView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 22.08.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class RatingView: UIControl {
    
    public enum Size {
        case small, big
        
        var height: CGFloat {
            switch self {
            case .small: return 8
            case .big: return 28
            }
        }
        
        var spacing: CGFloat {
            switch self {
            case .small: return 2
            case .big: return 8
            }
        }
        
        var icon: UIImage {
            switch self {
            case .small: return UIImage.asset(named: "star_small")!
            case .big: return UIImage.asset(named: "star_big")!
            }
        }
    }
        
    public var rating: Double = 0 {
        didSet {
            updateProgress()
            
            if rating != oldValue {
                sendActions(for: .valueChanged)
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(
            width: size.spacing * CGFloat(maxRating - 1) + size.height * CGFloat(maxRating),
            height: size.height
        )
    }
    
    public override var tintColor: UIColor! {
        didSet {
            progressLayer.fillColor = tintColor.cgColor
        }
    }
    
    private let progressLayer = CAShapeLayer()
    
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    private let maxRating: Double
    private let size: Size
    
    public init(maxRating: Double, size: Size) {
        self.maxRating = maxRating
        self.size = size
        
        super.init(frame: CGRect(x: 0, y: 0, width: size.spacing * CGFloat(maxRating - 1) + size.height * CGFloat(maxRating), height: size.height))
        
        configure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        touches.first.map { handleTouch(touch: $0) }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        touches.first.map { handleTouch(touch: $0) }
    }
    
    private func handleTouch(touch: UITouch) {
        let previousRating = rating
        
        let x = touch.location(in: self).x
        rating = max(Double(ceil(x / (size.height + size.spacing))), 1)
        
        if previousRating != rating {
            feedbackGenerator.selectionChanged()
        }
    }
    
    private func configure() {
        let starLayer = CALayer()
        starLayer.contents = size.icon.cgImage
        starLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.height)
        
        let maskLayer = CAReplicatorLayer()
        maskLayer.addSublayer(starLayer)
        maskLayer.instanceCount = Int(maxRating)
        maskLayer.instanceTransform = CATransform3DMakeTranslation(size.height + size.spacing, 0, 0)
        
        layer.mask = maskLayer
        
        layer.addSublayer(progressLayer)
        progressLayer.fillColor = UIColor.yellow.cgColor
        
        isEnabled = false
    }
    
    private func updateProgress() {
        progressLayer.frame = CGRect(x: 0, y: 0, width: bounds.width * CGFloat(rating / 5), height: size.height)
        progressLayer.path = UIBezierPath(rect: progressLayer.frame).cgPath
    }
    
}
