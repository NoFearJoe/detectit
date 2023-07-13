//
//  ProfileTaskScreen+Utils.swift
//  DetectIt
//
//  Created by Илья Харабет on 06/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension ProfileTaskScreen {
    
    func updateAnswerButtonState() {
        screenView.answerButton.isEnabled = answers.count == task.questions.count && score == nil
    }
    
    func finish() {
        view.endEditing(true)
        
        commitAnswers()

        updateContentState(animated: true)
        
        scrollToResults()
        
        AppRateManager.shared.commitEvent()
        
        Analytics.log(
            "profile_answer_sent",
            parameters: [
                "id": task.id,
                "answer": answers.answers.compactMap { $0.jsonString }
            ]
        )
    }
    
    func commitAnswers() {
        let totalScore = answers.answers.reduce(0) { result, answer in
            guard let question = task.questions.first(where: { $0.id == answer.questionID }) else {
                return result
            }
            
            let isCorrectAnswer = question.compare(with: answer.answer)
            let score = isCorrectAnswer ? question.score : 0
            
            return result + score
        }
        
        score = totalScore
        
        saveScoreAndAnswer(totalScore, answers: answers.answers)
    }
    
    func updateContentState(animated: Bool) {
        contentContainer.setChildHidden(screenView.answerButton, hidden: isSolved, animated: false)
        contentContainer.setChildHidden(screenView.scoreLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.crimeDescriptionTitleView, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.crimeDescriptionView, hidden: !isSolved || !FullVersionManager.hasBought, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.hiddenCrimeDescriptionView, hidden: !isSolved || FullVersionManager.hasBought, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.answersTitleView, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.answersView, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(taskSharingViewController, hidden: !isSolved, animated: animated, animationDuration: 2)
        
        screenView.scoreLabel.text = score.map { "\($0)/\(task.maxScore)" }
        screenView.scoreLabel.textColor = .score(value: score, max: task.maxScore, defaultColor: .white)
        screenView.crimeDescriptionView.attributedText = task.crimeDescription.readableAttributedText(font: screenView.crimeDescriptionView.font!)
        
        guard isSolved else { return }
        
        task.questions.enumerated().forEach { index, question in
            let answer = answers.get(questionID: question.id)
            let isCorrect = answer.map { question.compare(with: $0.answer) } ?? false
            let cell = screenView.reportView.getAnswerCell(at: index)
            
            cell?.setEnabled(!isSolved)
            cell?.highlight(isCorrect: isCorrect, animated: animated, animationDuration: 2)
        }
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
