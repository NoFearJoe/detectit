//
//  ProfileTaskAnswerCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 11/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public final class ProfileTaskAnswerCell: AutosizingCollectionViewCell {
    
    static let identifier = String(describing: ProfileTaskAnswerCell.self)
    
    private let questionLabel = UILabel()
    private let answerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        let question: String
        let answer: String
        
        public init(question: String, answer: String) {
            self.question = question
            self.answer = answer
        }
    }
    
    func configure(model: Model) {
        questionLabel.text = model.question
        answerLabel.text = model.answer
    }
    
    private func setupViews() {
        contentView.layoutMargins = .zero
        
        contentView.addSubview(questionLabel)
        
        questionLabel.font = .score2
        questionLabel.textColor = .lightGray
        questionLabel.numberOfLines = 0
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            questionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
        
        contentView.addSubview(answerLabel)
        
        answerLabel.font = .text2
        answerLabel.textColor = .white
        answerLabel.numberOfLines = 0
        
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 4),
            answerLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            answerLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            answerLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
}
