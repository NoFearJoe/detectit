//
//  ProfileTaskExactAnswerQuestionCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfileTaskExactAnswerQuestionCell: AutosizingCollectionViewCell {
    
    static let identifier = String(describing: ProfileTaskExactAnswerQuestionCell.self)
    
    let questionView = QuestionAndAnswerView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        public let question: String
        public let onChangeAnswer: (String) -> Void
        
        public init(question: String, onChangeAnswer: @escaping (String) -> Void) {
            self.question = question
            self.onChangeAnswer = onChangeAnswer
        }
    }
    
    func configure(model: Model) {
        questionView.configure(model: .init(question: model.question))
        questionView.onChangeAnswer = model.onChangeAnswer
    }
    
    private func setupViews() {
        contentView.addSubview(questionView)
        
        questionView.questionLabel.textColor = .white
        
        questionView.pin(to: contentView)
    }
    
}
