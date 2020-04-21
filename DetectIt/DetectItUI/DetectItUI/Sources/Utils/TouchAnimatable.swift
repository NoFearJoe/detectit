//
//  PressAnimatableViewTrait.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

/// View с анимацией нажатия. В будущем можно будет сделать layer анимацию, чтобы правильно обрабатывать прогресс анимации
class TouchAnimatableView: UIView, TouchAnimatable {
    
    var isTouchAnimationEnabled: Bool = true {
        didSet {
            isTouchAnimationEnabled ? self.enableTouchAnimation() : self.disableTouchAnimation()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isTouchAnimationEnabled = true
    }
    
}

public protocol TouchAnimatable: class {
    func enableTouchAnimation()
    func disableTouchAnimation()
}

public extension TouchAnimatable where Self: UIView {
    
    func enableTouchAnimation() {
        addTouchGestureRecognizer { [unowned self] recognizer in
            switch recognizer.state {
            case .began:
                self.animateTouchDown(scale: 0.975, duration: 0.1)
            case .ended, .cancelled, .failed:
                self.animateTouchUp(scale: 0.975, duration: 0.1)
            default: return
            }
        }
    }
    
    func disableTouchAnimation() {
        removeTouchGestureRecognizer()
    }
    
    private func animateTouchDown(scale: CGFloat, duration: TimeInterval) {
        let initialTransform = self.layer.presentation()?.transform ?? self.layer.transform
        let targetTransform = CATransform3DMakeScale(scale, scale, 1)
        let duration = duration * self.getTouchAnimationProgress(scale: scale)
        self.animateTouch(initialTransform: initialTransform, targetTransform: targetTransform, duration: duration)
    }
    
    private func animateTouchUp(scale: CGFloat, duration: TimeInterval) {
        let initialTransform = self.layer.presentation()?.transform ?? self.layer.transform
        let targetTransform = CATransform3DMakeScale(1, 1, 1)
        let duration = duration * (1 - self.getTouchAnimationProgress(scale: scale))
        self.animateTouch(initialTransform: initialTransform, targetTransform: targetTransform, duration: duration)
    }
    
    private func animateTouch(initialTransform: CATransform3D, targetTransform: CATransform3D, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = duration
        animation.fromValue = initialTransform
        animation.toValue = targetTransform
        layer.removeAnimation(forKey: "touch")
        layer.add(animation, forKey: "touch")
        layer.transform = targetTransform
    }
    
    private func getTouchAnimationProgress(scale: CGFloat) -> Double {
        guard let presentationLayer = self.layer.presentation() else { return 0 }
        return Double((presentationLayer.transform.m11 - scale) / (1 - scale))
    }
    
    private func addTouchGestureRecognizer(action: ((UIGestureRecognizer) -> Void)?) {
        guard self.gestureRecognizers == nil || !self.gestureRecognizers!.contains(where: { $0 is TouchGestureRecognizer }) else { return }
        let recognizer = TouchGestureRecognizer(action: action)
        recognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(recognizer)
    }
    
    private func removeTouchGestureRecognizer() {
        guard let recognizer = self.gestureRecognizers?.first(where: { $0 is TouchGestureRecognizer }) else { return }
        self.removeGestureRecognizer(recognizer)
    }
    
}
