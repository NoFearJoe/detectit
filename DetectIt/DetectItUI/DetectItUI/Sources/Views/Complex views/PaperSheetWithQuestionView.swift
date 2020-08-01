//
//  PaperSheetWithQuestionView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 24.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class QuestTaskChapterView: UIView {
    
    // MARK: - Public actions
    
    public var onSelectAnswer: ((Int) -> Void)?
    
    // MARK: - Model
    
    public struct Model {
        public let title: String
        public let text: String
        public let question: String
        public let answers: [String]
        public let selectedAnswerIndex: Int?
        
        public init(title: String, text: String, question: String, answers: [String], selectedAnswerIndex: Int?) {
            self.title = title
            self.text = text
            self.question = question
            self.answers = answers
            self.selectedAnswerIndex = selectedAnswerIndex
        }
    }
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let questionView = ProfileTaskVariantsQuestionCell()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public func configure(model: Model) {
        titleLabel.text = model.title
        textLabel.attributedText = model.text.readableAttributedText()
        
        questionView.configure(
            model: ProfileTaskVariantsQuestionCell.Model(
                question: model.question,
                variants: model.answers,
                selectedVariantIndex: model.selectedAnswerIndex,
                onSelectVariant: { [unowned self] index in
                    self.onSelectAnswer?(index)
                }
            )
        )
    }
    
    // MARK: - Setup
    
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(textLabel)
        
        titleLabel.font = .heading3
        titleLabel.textColor = .lightGray
        titleLabel.numberOfLines = 0
        
        textLabel.font = .text3
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        
        questionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20),
            questionView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            questionView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            questionView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
}
