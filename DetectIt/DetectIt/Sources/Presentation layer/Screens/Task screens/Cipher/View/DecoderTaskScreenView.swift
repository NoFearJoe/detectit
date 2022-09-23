//
//  DecoderTaskScreenView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 06/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public final class DecoderTaskScreenView {
    
    public var onTapEncodedPicture: (() -> Void)?
    public var onTapAnswerButton: (() -> Void)?
    
    public let titleLabel = UILabel()
    public let prepositionView = TextView()
    
    public let encodedPictureContainer = UIView()
    private let encodedPictureSizingContainer = UIView()
    public let encodedPictureView = AutosizingImageView()
    
    public let audioPlayerController = AudioPlayerController()
    
    public let questionAndAnswerView = QuestionAndAnswerView()
    
    public let answerButton = AnswerButton()
    
    public let scoreLabel = UILabel()
    public let rightAnswerView = DecoderTaskRightAnswerView()
    public let crimeDescriptionView = TextView()
    
    public func setupViews() {
        titleLabel.font = .heading1
        titleLabel.textColor = .softWhite
        titleLabel.numberOfLines = 0
        
        encodedPictureContainer.addSubview(encodedPictureSizingContainer)
        
        encodedPictureSizingContainer.translatesAutoresizingMaskIntoConstraints = false
        encodedPictureSizingContainer.topAnchor.constraint(equalTo: encodedPictureContainer.topAnchor).isActive = true
        encodedPictureSizingContainer.bottomAnchor.constraint(equalTo: encodedPictureContainer.bottomAnchor).isActive = true
        encodedPictureSizingContainer.centerXAnchor.constraint(equalTo: encodedPictureContainer.centerXAnchor).isActive = true
        if UIDevice.current.userInterfaceIdiom == .pad {
            encodedPictureSizingContainer.widthAnchor.constraint(equalTo: encodedPictureContainer.widthAnchor, multiplier: 0.5).isActive = true
        } else {
            encodedPictureSizingContainer.leadingAnchor.constraint(equalTo: encodedPictureContainer.leadingAnchor).isActive = true
        }
        
        encodedPictureSizingContainer.addSubview(encodedPictureView)
        
        encodedPictureView.contentMode = .scaleAspectFit
        encodedPictureView.layer.allowsEdgeAntialiasing = true
        
        encodedPictureView.configureShadow(radius: 20, opacity: 0.2, color: .white, offset: .zero)
        
        encodedPictureView.isUserInteractionEnabled = true
        encodedPictureView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapEncodedPicture))
        )
        
        encodedPictureView.pin(to: encodedPictureSizingContainer)
        
        // Audio player
        
        audioPlayerController.view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // Question and answer
        
        questionAndAnswerView.onChangeAnswer = { [unowned self] answer in
            self.answerButton.isEnabled = !answer.isEmpty
        }
        
        answerButton.isEnabled = false
        answerButton.titleLabel.text = "decoder_task_screen_send_answer_button_title".localized
        answerButton.onFill = { [unowned self] in
            self.onTapAnswerButton?()
        }
        
        scoreLabel.font = .score1
        scoreLabel.textColor = .softWhite
        scoreLabel.textAlignment = .center
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
        titleLabel.textColor = .softWhite
        titleLabel.text = "decoder_task_screen_right_answer_title".localized
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(answerLabel)
        
        answerLabel.font = .heading3
        answerLabel.textColor = .green
        answerLabel.numberOfLines = 0
        
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
