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
        get {
            answerField.answer
        }
        set {
            answerField.answer = newValue
        }
    }
    
    public var keyboardType: UIKeyboardType = .default {
        didSet {
            answerField.keyboardType = keyboardType
        }
    }
    
    // MARK: - Subviews
    
    public let questionLabel = UILabel()
    public let answerField: AnswerField
    
    // MARK: - Init
        
    public init(kind: AnswerField.Kind = .textView) {
        answerField = AnswerField(kind: kind)
        
        super.init(frame: .zero)
        
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    public override func becomeFirstResponder() -> Bool {
        answerField.becomeFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        answerField.resignFirstResponder()
    }
    
    public override var isFirstResponder: Bool {
        answerField.isFirstResponder
    }
    
    // MARK: - Configuration
    
    public struct Model {
        public let question: String
        public let answer: String?
        
        public init(question: String, answer: String?) {
            self.question = question
            self.answer = answer
        }
    }
    
    public func configure(model: Model) {
        questionLabel.text = model.question
        answerField.answer = model.answer ?? ""
    }
    
    public func highlight(isCorrect: Bool?, animated: Bool, animationDuration: TimeInterval) {
        answerField.highlight(isCorrect: isCorrect, animated: animated, animationDuration: animationDuration)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        layoutMargins = .zero
        
        addSubview(questionLabel)
        
        questionLabel.font = .heading4
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
