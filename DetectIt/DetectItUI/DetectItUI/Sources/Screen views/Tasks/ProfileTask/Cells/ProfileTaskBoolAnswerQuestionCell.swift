//
//  ProfileTaskBoolAnswerQuestionCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfileTaskBoolAnswerQuestionCell: UIView {
        
    private let titleLabel = UILabel()
    private let variantsContainer = UIStackView()
    
    private let trueAnswerView = makeVariantView(title: "profile_task_screen_answer_yes_title".localized)
    private let falseAnswerView = makeVariantView(title: "profile_task_screen_answer_no_title".localized)
    
    var selectedVariantView: AnswerVariantView? {
        trueAnswerView.isSelected ? trueAnswerView : falseAnswerView.isSelected ? falseAnswerView : nil
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        public let question: String
        public let answer: Bool?
        public let onSelectAnswer: (Bool) -> Void
        
        public init(question: String, answer: Bool?, onSelectAnswer: @escaping (Bool) -> Void) {
            self.question = question
            self.answer = answer
            self.onSelectAnswer = onSelectAnswer
        }
    }
    
    func configure(model: Model) {
        titleLabel.text = model.question
        
        updateSelectedVariant(answer: model.answer)
        
        trueAnswerView.onTap = { [unowned self] in
            self.updateSelectedVariant(answer: true)
            model.onSelectAnswer(true)
        }
        falseAnswerView.onTap = { [unowned self] in
            self.updateSelectedVariant(answer: false)
            model.onSelectAnswer(false)
        }
    }
    
    private func updateSelectedVariant(answer: Bool?) {
        trueAnswerView.isSelected = answer == true
        falseAnswerView.isSelected = answer == false
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        
        titleLabel.font = .heading4
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(variantsContainer)
        
        variantsContainer.axis = .horizontal
        variantsContainer.distribution = .fillEqually
        variantsContainer.alignment = .fill
        
        variantsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            variantsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            variantsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            variantsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            variantsContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        variantsContainer.addArrangedSubview(trueAnswerView)
        variantsContainer.addArrangedSubview(falseAnswerView)
    }
    
    private static func makeVariantView(title: String) -> AnswerVariantView {
        let view = AnswerVariantView()
        
        view.titleLabel.text = title
        view.titleLabel.textAlignment = .center
        
        return view
    }
    
}
