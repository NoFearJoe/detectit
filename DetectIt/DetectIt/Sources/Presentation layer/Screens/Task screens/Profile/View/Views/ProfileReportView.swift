//
//  ProfileReportView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 16/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol ProfileReportViewDelegate: AnyObject {
    func numberOfQuestions() -> Int
    func question(at index: Int) -> (question: Any, isCorrect: Bool?)?
}

public final class ProfileReportView: UIStackView {
    
    private unowned let delegate: ProfileReportViewDelegate
    
    public init(delegate: ProfileReportViewDelegate) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        axis = .vertical
        distribution = .fill
        alignment = .fill
        spacing = 40
    }
    
    required init(coder: NSCoder) { fatalError() }
    
    public func reloadData() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        let questionsCount = delegate.numberOfQuestions()
        
        for i in 0..<questionsCount {
            guard let question = delegate.question(at: i) else { return }
            guard let cell = cell(for: question) else { return }
            
            addArrangedSubview(cell)
        }
    }
    
    public func getAnswerCell(at index: Int) -> ProfileTaskAnyAnswerCell? {
        guard arrangedSubviews.indices.contains(index) else { return nil }
        
        return arrangedSubviews[index] as? ProfileTaskAnyAnswerCell
    }
    
    private func cell(for model: (question: Any, isCorrect: Bool?)) -> UIView? {
        if let numberQuestionModel = model.question as? ProfileTaskNumberQuestionCell.Model {
            let cell = ProfileTaskNumberQuestionCell()
            
            cell.configure(model: numberQuestionModel)
            cell.setEnabled(model.isCorrect == nil)
            
            if let isCorrect = model.isCorrect {
                cell.highlight(isCorrect: isCorrect, animated: false, animationDuration: 0)
            }
            
            return cell
        } else if let exactAnswerQuestionModel = model.question as? ProfileTaskExactAnswerQuestionCell.Model {
            let cell = ProfileTaskExactAnswerQuestionCell()
            
            cell.configure(model: exactAnswerQuestionModel)
            cell.setEnabled(model.isCorrect == nil)
            
            if let isCorrect = model.isCorrect {
                cell.highlight(isCorrect: isCorrect, animated: false, animationDuration: 0)
            }
            
            return cell
        } else if let variantsQuestionModel = model.question as? ProfileTaskVariantsQuestionCell.Model {
            let cell = ProfileTaskVariantsQuestionCell()
            
            cell.configure(model: variantsQuestionModel)
            cell.setEnabled(model.isCorrect == nil)
            
            if let isCorrect = model.isCorrect {
                cell.highlight(isCorrect: isCorrect, animated: false, animationDuration: 0)
            }
            
            return cell
        } else if let boolAnswerQuestionModel = model.question as? ProfileTaskBoolAnswerQuestionCell.Model {
            let cell = ProfileTaskBoolAnswerQuestionCell()
            
            cell.configure(model: boolAnswerQuestionModel)
            cell.setEnabled(model.isCorrect == nil)
            
            if let isCorrect = model.isCorrect {
                cell.highlight(isCorrect: isCorrect, animated: false, animationDuration: 0)
            }
            
            return cell
        } else {
            return nil
        }
    }
    
}
