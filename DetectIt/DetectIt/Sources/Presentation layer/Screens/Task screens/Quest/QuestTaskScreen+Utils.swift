//
//  QuestTaskScreen+Utils.swift
//  DetectIt
//
//  Created by Илья Харабет on 19.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore
import DetectItUI

extension QuestTaskScreen {
    
    func finish() {
        view.endEditing(true)
        
        commitAnswers()

        updateContentState(animated: true)
        
        scrollToResults()
        
        AppRateManager.shared.commitEvent()
        
        if let answer = state.answer?.jsonString {
            Analytics.log("quest_answer_sent", parameters: ["answer": answer])
        }
    }
    
    func commitAnswers() {
        guard let score = state.score, let answer = state.answer else { return }
        
        saveScoreAndAnswer(score: score, answer: answer) { success in
            print(success)
        }
    }
    
    func updateContentState(animated: Bool) {
        contentContainer.setChildHidden(screenView.scoreLabel, hidden: !state.isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.endingTitleView, hidden: !state.isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.endingTextLabel, hidden: !state.isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(rateTaskViewController, hidden: !state.isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(taskSharingViewController, hidden: !state.isSolved, animated: animated, animationDuration: 2)
        
        screenView.scoreLabel.text = state.score.map { "\($0)/\(state.task.maxScore)" }
        screenView.scoreLabel.textColor = .score(value: state.score, max: state.task.maxScore, defaultColor: .white)
        
        screenView.endingTextLabel.attributedText = state.ending?.text.readableAttributedText(font: screenView.endingTextLabel.font)
    }
    
    func scrollToResults() {
        view.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let topInset = self.view.safeAreaInsets.top + Constants.spacingBeforeScore
            let bottomInset = self.view.safeAreaInsets.bottom + Constants.bottomInset
            
            let minY = self.screenView.scoreLabel.frame.minY - topInset
            let maxY = self.screenView.endingTextLabel.frame.maxY + bottomInset
            
            let targetY = maxY - minY > self.view.bounds.height ? minY : max(0, maxY - self.view.bounds.height)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.contentContainer.scrollView.contentOffset = CGPoint(x: 0, y: targetY)
            }) { _ in
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func mapChapterEntityToModel(entity: QuestTask.Chapter) -> QuestTaskChapterView.Model {
        QuestTaskChapterView.Model(
            text: entity.text,
            isActive: state.currentChapter?.id == entity.id,
            actions: entity.actions.map { $0.title },
            selectedActionIndex: entity.actions.firstIndex { action in
                if let targetChapterID = action.targetChapterID {
                    return state.answer?.routes.contains {
                        $0.toChapter == targetChapterID
                    } == true
                } else if let targetEndingID = action.targetEndingID {
                    return state.answer?.ending?.toChapter == targetEndingID
                } else {
                    return false
                }
            }
        )
    }
    
}
