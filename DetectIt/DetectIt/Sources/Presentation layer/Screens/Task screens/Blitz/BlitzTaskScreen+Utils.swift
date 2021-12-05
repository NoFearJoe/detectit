//
//  BlitzTaskScreen+Utils.swift
//  DetectIt
//
//  Created by Илья Харабет on 21.11.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension BlitzTaskScreen {
    
    func updateAnswerButtonState() {
        screenView.answerButton.isEnabled = answer.answer != nil && score == nil
    }
    
    func finish() {
        view.endEditing(true)
        
        commitAnswers()

        updateContentState(animated: true)
        
        scrollToResults()
        
        AppRateManager.shared.commitEvent()
        
        Analytics.log(
            "blitz_answer_sent",
            parameters: [
                "id": task.id,
                "answer": answer.answer?.jsonString ?? ""
            ]
        )
    }
    
    func commitAnswers() {
        score = answer.answer.flatMap {
            task.question.compare(with: $0.answer) ? task.question.score : 0
        }
        
        if let answer = answer.answer {
            saveScoreAndAnswer(score ?? 0, answer: answer) { success in
                print(success)
            }
        }
    }
    
    func updateContentState(animated: Bool) {
        contentContainer.setChildHidden(screenView.answerButton, hidden: isSolved, animated: false)
        contentContainer.setChildHidden(screenView.scoreLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.crimeDescriptionTitleView, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.crimeDescriptionView, hidden: !isSolved || !FullVersionManager.hasBought, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(
            screenView.crimeDescriptionAttachmentsView,
            hidden: !isSolved || !FullVersionManager.hasBought || task.crimeDescriptionAttachments == nil,
            animated: animated,
            animationDuration: 2
        )
        contentContainer.setChildHidden(screenView.hiddenCrimeDescriptionView, hidden: !isSolved || FullVersionManager.hasBought, animated: animated, animationDuration: 2)
        if !isSolved {
            contentContainer.setChildHidden(screenView.rightAnswerView, hidden: true, animated: animated, animationDuration: 2)
        }
        contentContainer.setChildHidden(rateTaskViewController, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(taskSharingViewController, hidden: !isSolved, animated: animated, animationDuration: 2)
        
        screenView.scoreLabel.text = score.map { "\($0)/\(task.maxScore)" }
        screenView.scoreLabel.textColor = .score(value: score, max: task.maxScore, defaultColor: .white)
        screenView.crimeDescriptionView.attributedText = task.crimeDescription.readableAttributedText(font: screenView.crimeDescriptionView.font!)
        
        guard isSolved else { return }
        
        let answer = answer.answer
        let isCorrect = answer.map { task.question.compare(with: $0.answer) } ?? false
        let cell = screenView.reportView.getAnswerCell(at: 0)
        
        cell?.setEnabled(!isSolved)
        cell?.highlight(isCorrect: isCorrect, animated: animated, animationDuration: 2)
        
        contentContainer.setChildHidden(screenView.rightAnswerView, hidden: isCorrect, animated: animated, animationDuration: 2)
    }
    
    func scrollToResults() {
        view.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let topInset = self.view.safeAreaInsets.top + Constants.spacingBeforeScore
            let bottomInset = self.view.safeAreaInsets.bottom + Constants.bottomInset
            
            let minY = self.screenView.scoreLabel.frame.minY - topInset
            let maxY = self.taskSharingViewController.view.frame.maxY + bottomInset
            
            let targetY = maxY - minY > self.view.bounds.height ? minY : max(0, maxY - self.view.bounds.height)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.contentContainer.scrollView.contentOffset = CGPoint(x: 0, y: targetY)
            }) { _ in
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
}
