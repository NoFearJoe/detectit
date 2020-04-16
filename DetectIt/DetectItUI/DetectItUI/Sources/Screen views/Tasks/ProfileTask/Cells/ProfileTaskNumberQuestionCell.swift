//
//  ProfileTaskNumberQuestionCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfileTaskNumberQuestionCell: UIView {
        
    let questionView = QuestionAndAnswerView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        public let question: String
        public let onChangeAnswer: (Int?) -> Void
        
        public init(question: String, onChangeAnswer: @escaping (Int?) -> Void) {
            self.question = question
            self.onChangeAnswer = onChangeAnswer
        }
    }
    
    func configure(model: Model) {
        questionView.configure(model: .init(question: model.question))
        questionView.onChangeAnswer = {
            model.onChangeAnswer(Int($0))
        }
    }
    
    private func setupViews() {
        addSubview(questionView)
        
        questionView.keyboardType = .numberPad
        questionView.questionLabel.textColor = .white
        
        questionView.pin(to: self)
    }
    
}
