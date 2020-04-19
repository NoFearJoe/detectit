//
//  OnboardingEnterNamePage.swift
//  DetectIt
//
//  Created by Илья Харабет on 13/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class OnboardingEnterNamePage: Screen {
    
    var onFinish: (() -> Void)?
    
    private let containerView = UIStackView()
    private let nameField = QuestionAndAnswerView()
    private let subtitleLabel = UILabel()
    private let continueButton = AnswerButton()
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .black
        
        view.addSubview(containerView)
        
        containerView.axis = .vertical
        containerView.distribution = .fill
        containerView.alignment = .fill
        containerView.spacing = 12
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        containerView.addArrangedSubview(nameField)
        containerView.addArrangedSubview(subtitleLabel)
        
        nameField.configure(model: .init(question: "А вот и твой первый вопрос - какой у тебя оперативный псевдоним?", answer: nil))
        nameField.onChangeAnswer = { [unowned self] answer in
            self.continueButton.isEnabled = !answer.isEmpty
        }
        
        subtitleLabel.font = .text3
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = "Как только введешь псевдоним, тебе предстоит приноровиться к несовсем обычной кнопке, которая служит для фиксации ответа."
        
        view.addSubview(continueButton)
        
        continueButton.isEnabled = false
        continueButton.titleLabel.text = "Приступить к расследованию" // TODO
        continueButton.onFill = { [unowned self] in
            self.didTapContinueButton()
        }
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    private func didTapContinueButton() {
        User.shared.alias = nameField.answer
        
        onFinish?()
    }
    
    @objc private func didTapBackground() {
        view.endEditing(true)
    }
    
}
