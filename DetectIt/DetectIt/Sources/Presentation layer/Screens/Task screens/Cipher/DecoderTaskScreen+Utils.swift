//
//  DecoderTaskScreen+Utils.swift
//  DetectIt
//
//  Created by Илья Харабет on 06/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

extension DecoderTaskScreen {
    
    func commitAnswer() {
        let answer = screenView.questionAndAnswerView.answer
        
        let isCorrectAnswer = task.answer.compare(with: answer)
        let score = isCorrectAnswer ? task.maxScore : 0
        
        self.score = score
        
        updateContentState(animated: true)
        
        saveScoreAndAnswer(score, answer: answer) { success in
            print(success)
        }
    }
        
    func displayContent(encodedPicture: UIImage) {
        screenView.titleLabel.text = task.title
        screenView.prepositionLabel.attributedText = task.preposition.readableAttributedText()
        screenView.encodedPictureView.image = encodedPicture
        screenView.questionAndAnswerView.configure(
            model: QuestionAndAnswerView.Model(
                question: "decoder_task_screen_answer_title".localized,
                answer: answer
            )
        )
        screenView.crimeDescriptionLabel.attributedText = task.answer.crimeDescription.readableAttributedText()
        screenView.rightAnswerView.answer = task.answer.decodedMessage
    }
    
    func updateContentState(animated: Bool) {
        // Если есть счет, значит задание решено
        let isSolved = score != nil
        let isSolvedCorrectly = score == task.maxScore
        
        contentContainer.setChildHidden(screenView.answerButton, hidden: isSolved, animated: false)
        contentContainer.setChildHidden(screenView.scoreLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.crimeDescriptionLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.rightAnswerView, hidden: !isSolved || isSolvedCorrectly, animated: animated, animationDuration: 2)
        
        screenView.scoreLabel.text = score.map { "\($0)/\(task.maxScore)" }
        screenView.scoreLabel.textColor = .score(value: score, max: task.maxScore, defaultColor: .white)
        
        screenView.questionAndAnswerView.isUserInteractionEnabled = !isSolved
        
        guard isSolved else { return }
        
        screenView.questionAndAnswerView.highlight(isCorrect: isSolvedCorrectly, animated: animated, animationDuration: 2)
    }
    
    func scrollToResults() {
        view.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let topInset = self.view.safeAreaInsets.top + Constants.spacingBeforeScore
            let bottomInset = self.view.safeAreaInsets.bottom + Constants.bottomInset
            
            let minY = self.screenView.scoreLabel.frame.minY - topInset
            let maxY = self.screenView.crimeDescriptionLabel.frame.maxY + bottomInset
            
            let targetY = maxY - minY > self.view.bounds.height ? minY : max(0, maxY - self.view.bounds.height)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.contentContainer.scrollView.contentOffset = CGPoint(x: 0, y: targetY)
            }) { _ in
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
}
