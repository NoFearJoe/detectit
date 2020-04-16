//
//  ProfileTaskAnyAnswerCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 10/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol ProfileTaskAnyAnswerCell: UIView {
    
    func setEnabled(_ isEnabled: Bool)
    
    func highlight(isCorrect: Bool, animated: Bool, animationDuration: TimeInterval)
    
}

extension ProfileTaskAnyAnswerCell {
    
    public func setEnabled(_ isEnabled: Bool) {
        isUserInteractionEnabled = isEnabled
    }
    
}

extension ProfileTaskNumberQuestionCell: ProfileTaskAnyAnswerCell {
    
    public func highlight(isCorrect: Bool, animated: Bool, animationDuration: TimeInterval) {
        questionView.highlight(isCorrect: isCorrect, animated: animated, animationDuration: animationDuration)
    }
    
}

extension ProfileTaskExactAnswerQuestionCell: ProfileTaskAnyAnswerCell {
    
    public func highlight(isCorrect: Bool, animated: Bool, animationDuration: TimeInterval) {
        questionView.highlight(isCorrect: isCorrect, animated: animated, animationDuration: animationDuration)
    }
    
}

extension ProfileTaskVariantsQuestionCell: ProfileTaskAnyAnswerCell {
    
    public func highlight(isCorrect: Bool, animated: Bool, animationDuration: TimeInterval) {
        guard let label = selectedVariantView?.titleLabel else { return }
        
        UIView.transition(
            with: label,
            duration: animationDuration,
            options: .transitionCrossDissolve,
            animations: { label.textColor = isCorrect ? .green : .red },
            completion: nil
        )
    }
    
}

extension ProfileTaskBoolAnswerQuestionCell: ProfileTaskAnyAnswerCell {
    
    public func highlight(isCorrect: Bool, animated: Bool, animationDuration: TimeInterval) {
        guard let label = selectedVariantView?.titleLabel else { return }
        
        UIView.transition(
            with: label,
            duration: animationDuration,
            options: .transitionCrossDissolve,
            animations: { label.textColor = isCorrect ? .green : .red },
            completion: nil
        )
    }
    
}
