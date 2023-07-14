//
//  AnswerButton.swift
//  DetectItUI
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class AnswerButton: UIControl {
    
    public var onFill: (() -> Void)?
    
    public var heightConstraint: NSLayoutConstraint!
    
    public let titleLabel = UILabel()
    private let fillView = UIView()
    
    private var fillViewTrailingConstraint: NSLayoutConstraint!
    
    private lazy var fillAnimator = UIViewPropertyAnimator(duration: 0.75, curve: .easeOut) { [weak self] in
        guard let self = self else { return }
        
        self.fillView.bounds.size.width = self.bounds.width
    }
    
    private var fillAnimatorIsRunningObservation: NSKeyValueObservation!
        
    private var hasBeenFilled = false
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private var impactOccured = false
    
    private func setupViews() {
        clipsToBounds = true
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        backgroundColor = .darkGray
        translatesAutoresizingMaskIntoConstraints = false
        
        heightConstraint = heightAnchor.constraint(equalToConstant: 52)
        heightConstraint.isActive = true
        
        addSubview(fillView)
        
        fillView.layer.cornerRadius = 12
        fillView.layer.cornerCurve = .continuous
        fillView.backgroundColor = .yellow
        fillView.layer.anchorPoint.x = 0
                
        fillView.calculateFrame(container: self, onChangeContainerBounds: { [unowned self] bounds in
            var bounds = bounds
            bounds.size.width = self.bounds.width * self.fillAnimator.fractionComplete
            return bounds
        })
        
        addSubview(titleLabel)
        
        titleLabel.font = .text2
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        titleLabel.text = "answer_button_default_title".localized
        
        titleLabel.pin(to: self, insets: UIEdgeInsets(top: 8, left: 16, bottom: -8, right: -16))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
        feedbackGenerator.prepare()
        
        fillAnimator.pausesOnCompletion = true
        fillAnimatorIsRunningObservation = fillAnimator.observe(\.isRunning, options: .new) { [weak self] animator, change in
            guard
                let self = self,
                let isRunning = change.newValue,
                !isRunning,
                !self.impactOccured,
                animator.fractionComplete >= 1,
                !animator.isReversed
            else { return }
            
            self.feedbackGenerator.impactOccurred()
            self.impactOccured = true
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        fillAnimator.stopAnimation(true)
    }
    
    public func reset() {
        isUserInteractionEnabled = true
        cancelFillAnimator()
    }
    
    public func setFilled(_ isFilled: Bool) {
        hasBeenFilled = isFilled
        isUserInteractionEnabled = !isFilled
        fillAnimator.fractionComplete = isFilled ? 1 : 0
    }
    
    // MARK: - Overrides
    
    public override var isEnabled: Bool {
        didSet {
            fillView.backgroundColor = isEnabled ? .yellow : UIColor.yellow.withAlphaComponent(0.5)
            backgroundColor = isEnabled ? .gray : .darkGray.withAlphaComponent(0.5)
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        fillAnimator.isReversed = false
        
        runFillAnimator()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if touches.allSatisfy({ !self.bounds.contains($0.location(in: self)) }) {
            isUserInteractionEnabled = false
            isUserInteractionEnabled = true
            
            hasBeenFilled = false
            
            cancelFillAnimator()
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if fillAnimator.isReversed || fillAnimator.fractionComplete < 1 {
            cancelFillAnimator()
        } else {
            hasBeenFilled = true
        }
        
        guard hasBeenFilled else { return }
        
        isUserInteractionEnabled = false
        
        onFill?()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if touches.allSatisfy({ self.bounds.contains($0.location(in: self)) }), !fillAnimator.isReversed, fillAnimator.fractionComplete >= 1 {
            hasBeenFilled = true
            
            isUserInteractionEnabled = false
            
            onFill?()
        } else {
            cancelFillAnimator()
        }
    }
    
    // MARK: - Utils
    
    private func runFillAnimator() {
        fillAnimator.startAnimation()
        fillAnimator.pauseAnimation()
        fillAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 1)
    }
    
    private func cancelFillAnimator() {
        guard !fillAnimator.isReversed else { return }
                
        fillAnimator.isReversed = true
        fillAnimator.pauseAnimation()
        fillAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.5)
        
        impactOccured = false
    }
    
}
