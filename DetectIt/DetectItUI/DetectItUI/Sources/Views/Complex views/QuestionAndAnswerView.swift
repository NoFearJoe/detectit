//
//  QuestionAndAnswerView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class QuestionAndAnswerView: UIView {
    
    public var onChangeAnswer: ((String) -> Void)?
    
    public var answer: String {
        answerField.answer
    }
    
    // MARK: - Subviews
    
    private let questionLabel = UILabel()
    private let answerField = AnswerField()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        public let question: String
        
        public init(question: String) {
            self.question = question
        }
    }
    
    public func configure(model: Model) {
        questionLabel.text = model.question
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        layoutMargins = .zero
        
        addSubview(questionLabel)
        
        questionLabel.font = .bold(20)
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 0
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        
        addSubview(answerField)
        
        answerField.onChangeText = { [unowned self] text in
            self.onChangeAnswer?(text)
        }
        
        answerField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            answerField.topAnchor.constraint(equalTo: questionLabel.bottomAnchor),
            answerField.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            answerField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            answerField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
}
