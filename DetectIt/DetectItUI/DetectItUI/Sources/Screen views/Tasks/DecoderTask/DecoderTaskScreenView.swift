//
//  DecoderTaskScreenView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class DecoderTaskScreenView {
    
    public var onTapEncodedPicture: (() -> Void)?
    public var onTapAnswerButton: (() -> Void)?
    
    public let titleLabel = UILabel()
    public let prepositionLabel = UILabel()
    public let encodedPictureView = AutosizingImageView()
    
    public let questionAndAnswerView = QuestionAndAnswerView()
    
    public let answerButton = AnswerButton()
    
    public let scoreLabel = UILabel()
    public let rightAnswerView = DecoderTaskRightAnswerView()
    public let crimeDescriptionLabel = UILabel()
    
    public func setupViews() {
        titleLabel.font = .heading2
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        prepositionLabel.font = .text3
        prepositionLabel.textColor = .white
        prepositionLabel.numberOfLines = 0
        
        encodedPictureView.contentMode = .scaleAspectFit
        encodedPictureView.layer.allowsEdgeAntialiasing = true
        encodedPictureView.transform = CGAffineTransform
            .randomLayout()
            .concatenating(CGAffineTransform(scaleX: 0.9, y: 0.9))
        
        encodedPictureView.configureShadow(radius: 20, opacity: 0.2, color: .white, offset: .zero)
        
        encodedPictureView.isUserInteractionEnabled = true
        encodedPictureView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapEncodedPicture))
        )
        
        questionAndAnswerView.onChangeAnswer = { [unowned self] answer in
            self.answerButton.isEnabled = !answer.isEmpty
        }
        
        answerButton.isEnabled = false
//        answerButton.setTitle("Отправить ответ", for: .normal) // TODO
        answerButton.onFill = { [unowned self] in
            self.onTapAnswerButton?()
        }
        
        scoreLabel.font = .score1
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        
        crimeDescriptionLabel.font = .text3
        crimeDescriptionLabel.textColor = .white
        crimeDescriptionLabel.numberOfLines = 0
    }
    
    @objc private func didTapEncodedPicture() {
        onTapEncodedPicture?()
    }
    
    public init() {}
    
}

public final class DecoderTaskRightAnswerView: UIView {
    
    public var answer: String? {
        didSet {
            answerLabel.text = answer
        }
    }
    
    private let titleLabel = UILabel()
    private let answerLabel = UILabel()
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        
        titleLabel.font = .text3
        titleLabel.textColor = .white
        titleLabel.text = "Правильный ответ:" // TODO
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(answerLabel)
        
        answerLabel.font = .heading3
        answerLabel.textColor = .green
        answerLabel.adjustsFontSizeToFitWidth = true
        
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            answerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            answerLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            answerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            answerLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
}
