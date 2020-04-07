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
    
    private let titleLabel = UILabel()
    private let fillView = UIView()
    
    private var fillViewTrailingConstraint: NSLayoutConstraint!
    
    private var animator: UIViewPropertyAnimator?
    
    private var rollbackAnimator: UIViewPropertyAnimator?
    
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
        titleLabel.text = "Отправить ответ" // TODO
        
        titleLabel.pin(to: self)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        
        feedbackGenerator.prepare()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Overrides
    
    public override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .gray : .darkGray
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        rollbackAnimator?.stopAnimation(true)
        rollbackAnimator = nil
        
        runFillAnimator()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if touches.allSatisfy({ !self.bounds.contains($0.location(in: self)) }) {
            isUserInteractionEnabled = false
            isUserInteractionEnabled = true
            
            hasBeenFilled = false
            
            if animator != nil {
                cancelFillAnimator()
            } else {
                runRollbackAnimator()
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let animator = animator, animator.fractionComplete < 1 {
            cancelFillAnimator()
        }
        
        guard hasBeenFilled else { return }
        
        isUserInteractionEnabled = false
        
        onFill?()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if animator != nil {
            cancelFillAnimator()
        } else {
            runRollbackAnimator()
        }
    }
    
    // MARK: - Utils
    
    private func runFillAnimator() {
        animator = UIViewPropertyAnimator(duration: 1, curve: .easeOut) {
            self.fillViewTrailingConstraint.constant = self.bounds.width
            self.layoutIfNeeded()
        }
        
        animator?.addCompletion { position in
            self.animator = nil
            
            switch position {
            case .current:
                self.runRollbackAnimator()
            case .end:
                self.hasBeenFilled = true
                self.feedbackGenerator.impactOccurred()
            case .start:
                return
            @unknown default:
                return
            }
        }
        
        animator?.startAnimation()
    }
    
    private func cancelFillAnimator() {
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .current)
    }
    
    private func runRollbackAnimator() {
        rollbackAnimator = UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.fillViewTrailingConstraint.constant = 0
            self.layoutIfNeeded()
        }
        
        rollbackAnimator?.addCompletion { _ in
            self.rollbackAnimator = nil
        }
        
        rollbackAnimator?.startAnimation()
    }
    
}
