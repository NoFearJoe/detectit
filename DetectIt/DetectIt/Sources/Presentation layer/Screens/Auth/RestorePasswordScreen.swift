//
//  RestorePasswordScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 19.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItAPI
import DetectItCore

final class RestorePasswordScreen: Screen {
    
    private let containerView = UIStackView()
    
    private let titleLabel = UILabel()
    private let emailField = QuestionAndAnswerView(kind: .textField)
    private let continueButton = AnswerButton()
    
    private var continueButtonBottomConstraint: NSLayoutConstraint!
    
    private let keyboardManager = KeyboardManager()
    
    private let api = DetectItAPI()
    
    private var email: String?
    
    init(email: String?) {
        self.email = email
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepare() {
        super.prepare()
                        
        setupViews()
        
        setupKeyboardManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let email = email {
            emailField.answer = email
            updateContinueButtonState()
        } else {
            _ = emailField.becomeFirstResponder()
        }
    }
    
    private func restorePassword() {
        guard let email = email else { return }
        
        showLoadingHUD(title: nil)
        
        api.request(.restorePassword(email: email)) { [weak self] result in
            switch result {
            case let .success(response):
                if response.statusCode == 401 {
                    self?.continueButton.reset()
                    
                    let payload = try? JSONDecoder().decode(ErrorPayload.self, from: response.data)
                    switch payload?.reason {
                    case "no_email":
                        self?.showErrorHUD(title: "auth_email_busy_error_title".localized) // TODO
                    default:
                        self?.showErrorHUD(title: "auth_401_error_title".localized)
                    }
                    
                    self?.hideHUD(after: 3)
                } else if response.statusCode == 200 {
//                    self?.onFinish?() TODO
                } else {
                    self?.continueButton.reset()
                    self?.showErrorHUD(title: "network_error_title".localized)
                    self?.hideHUD(after: 2)
                }
            case .failure:
                self?.continueButton.reset()
                self?.showErrorHUD(title: "network_error_title".localized)
                self?.hideHUD(after: 2)
            }
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(containerView)
        
        containerView.axis = .vertical
        containerView.distribution = .fill
        containerView.alignment = .fill
        containerView.spacing = 8
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let containerViewTopConstraint = containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        containerViewTopConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerViewTopConstraint,
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset)
        ])
        
        containerView.addArrangedSubview(titleLabel)
        containerView.addArrangedSubview(emailField)
        
        containerView.setCustomSpacing(32, after: titleLabel)
        containerView.setCustomSpacing(2, after: emailField)
        
        titleLabel.text = "restore_password_title".localized
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        emailField.keyboardType = .emailAddress
        emailField.configure(model: .init(question: "auth_email_title".localized, answer: nil))
        emailField.setContentCompressionResistancePriority(.required, for: .vertical)
        emailField.highlight(isCorrect: nil, animated: false, animationDuration: 0)
        emailField.onChangeAnswer = { [unowned self] answer in
            self.email = answer
            self.updateContinueButtonState()
            self.emailField.highlight(isCorrect: self.isValidEmail(answer), animated: false, animationDuration: 0)
        }
        
        // Continue button
        
        view.addSubview(continueButton)
        
        continueButton.isEnabled = false
        continueButton.titleLabel.text = "restore_password_continue_button_title".localized
        continueButton.onFill = { [unowned self] in
            self.restorePassword()
            self.view.endEditing(true)
        }
        
        continueButtonBottomConstraint = continueButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -12
        )
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: 12),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
            continueButtonBottomConstraint
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    private func updateContinueButtonState() {
        continueButton.isEnabled = isValidEmail(email)
    }
    
    func isValidEmail(_ email: String?) -> Bool {
        guard let email = email, !email.isEmpty else { return false }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
