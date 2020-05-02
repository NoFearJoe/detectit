//
//  OnboardingCreateOrGetUserScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 28/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore
import DetectItAPI

final class OnboardingAuthScreen: Screen {
    
    var onFinish: (() -> Void)?
    
    private let skeleton = ScreenLoadingView(isInitiallyHidden: true)
    
    private let containerView = UIStackView()
    private let titleLabel = UILabel()
    private let aliasField = QuestionAndAnswerView()
    private let passwordField = QuestionAndAnswerView()
    private let continueButton = AnswerButton()
    
    private var continueButtonBottomConstraint: NSLayoutConstraint!
    
    private let keyboardManager = KeyboardManager()
    
    private let api = DetectItAPI()
    
    private var alias: String?
    private var password: String?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepare() {
        super.prepare()
        
        User.shared.isOnboardingShown = true
        
        view.addSubview(skeleton)
        
        skeleton.pin(to: self.view)
        
        setupViews()
        
        setupKeyboardManager()
    }
    
    private func auth() {
        guard let alias = alias, let password = password else { return }
        
        showLoadingHUD(title: nil)
        
        api.request(.auth(alias: alias, password: password)) { [weak self] result in
            switch result {
            case let .success(response):
                if response.statusCode == 401 {
                    self?.continueButton.reset()
                    
                    self?.showErrorHUD(title: "auth_401_error_title".localized)
                    self?.hideHUD(after: 2)
                } else if response.statusCode == 200 {
                    User.shared.alias = alias
                    User.shared.password = password
                    
                    self?.onFinish?()
                } else {
                    self?.showErrorHUD(title: "network_error_title".localized)
                    self?.hideHUD(after: 2)
                }
            case .failure:
                self?.showErrorHUD(title: "network_error_title".localized)
                self?.hideHUD(after: 2)
            }
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        
        view.addSubview(containerView)
        
        containerView.axis = .vertical
        containerView.distribution = .fill
        containerView.alignment = .fill
        containerView.spacing = 12
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset)
        ])
        
        containerView.addArrangedSubview(titleLabel)
        containerView.addArrangedSubview(aliasField)
        containerView.addArrangedSubview(passwordField)
        
        containerView.setCustomSpacing(48, after: titleLabel)
        
        titleLabel.text = "onboarding_auth_title".localized
        titleLabel.font = .heading3
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        aliasField.configure(model: .init(question: "onboarding_auth_alias_title".localized, answer: nil))
        aliasField.onChangeAnswer = { [unowned self] answer in
            self.alias = answer
            self.updateContinueButtonState()
        }
        
        passwordField.configure(model: .init(question: "onboarding_auth_password_title".localized, answer: nil))
        passwordField.onChangeAnswer = { [unowned self] answer in
            self.password = answer
            self.updateContinueButtonState()
        }
        
        view.addSubview(continueButton)
        
        continueButton.isEnabled = false
        continueButton.titleLabel.text = "onboarding_auth_continue_button_title".localized
        continueButton.onFill = { [unowned self] in
            self.auth()
        }
        
        continueButtonBottomConstraint = continueButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -12
        )
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
            continueButtonBottomConstraint
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    private func updateContinueButtonState() {
        let aliasValid = alias?.isEmpty == false
        let passwordValid = (password?.count ?? 0) > 5
        
        continueButton.isEnabled = aliasValid && passwordValid
    }
    
    @objc private func didTapBackground() {
        view.endEditing(true)
    }
    
    func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            self.continueButtonBottomConstraint.constant = -frame.height + self.view.safeAreaInsets.bottom - Constants.bottomInset
            
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            self.continueButtonBottomConstraint.constant = -Constants.bottomInset
            
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

private struct Constants {
    static let bottomInset = CGFloat(12)
}
