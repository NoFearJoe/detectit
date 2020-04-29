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
    
    public let titleLabel = UILabel()
    private let fillView = UIView()
    
    private var fillViewTrailingConstraint: NSLayoutConstraint!
    
    private lazy var fillAnimator = UIViewPropertyAnimator(duration: 0.75, curve: .easeOut) { [weak self] in
        guard let self = self else { return }
        
        self.fillViewTrailingConstraint.constant = self.bounds.width
        self.layoutIfNeeded()
    }
        
    private var hasBeenFilled = false
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    private func setupViews() {
        clipsToBounds = true
        layer.cornerRadius = 12
        backgroundColor = .darkGray
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52)
        ])
        
        addSubview(fillView)
        
        fillView.layer.cornerRadius = 12
        fillView.backgroundColor = .yellow
        
        fillView.translatesAutoresizingMaskIntoConstraints = false
        
        fillViewTrailingConstraint = fillView.trailingAnchor.constraint(equalTo: leadingAnchor)
        NSLayoutConstraint.activate([
            fillView.topAnchor.constraint(equalTo: topAnchor),
            fillView.leadingAnchor.constraint(equalTo: leadingAnchor),
            fillView.bottomAnchor.constraint(equalTo: bottomAnchor),
            fillViewTrailingConstraint
        ])
        
        addSubview(titleLabel)
        
        titleLabel.font = .text2
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        titleLabel.text = "answer_button_default_title".localized
        
        titleLabel.pin(to: self)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
        feedbackGenerator.prepare()
        
        fillAnimator.pausesOnCompletion = true
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        fillAnimator.stopAnimation(true)
    }
    
    // MARK: - Overrides
    
    public override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .gray : .darkGray
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
            feedbackGenerator.impactOccurred()
        }
        
        guard hasBeenFilled else { return }
        
        isUserInteractionEnabled = false
        
        onFill?()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        cancelFillAnimator()
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
    }
    
}
