//
//  AuthScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 28/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import Amplitude
import DetectItUI
import DetectItCore
import DetectItAPI

final class AuthScreen: Screen {
    
    var onFinish: (() -> Void)?
        
    private let containerView = UIStackView()
    private let titleLabel = UILabel()
    private let aliasField = QuestionAndAnswerView(kind: .textField)
    private let aliasHint = UILabel()
    private let emailField = QuestionAndAnswerView(kind: .textField)
    private let emailHint = UILabel()
    private let passwordField = QuestionAndAnswerView(kind: .textField)
    private let passwordHint = UILabel()
    private let authProblemsButton = SolidButton.makePushButton()
    private let continueButton = AnswerButton()
    
    private var continueButtonBottomConstraint: NSLayoutConstraint!
    
    private let keyboardManager = KeyboardManager()
    
    private let api = DetectItAPI()
    
    private var alias: String?
    private var email: String?
    private var password: String?
    
    override func prepare() {
        super.prepare()
        
        User.shared.isOnboardingShown = true
        
        setupViews()
        
        setupKeyboardManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = aliasField.becomeFirstResponder()
        
        Analytics.logScreenShow(.auth)
    }
    
    private func auth() {
        guard let alias = alias, let email = email, let password = password else { return }
        
        showLoadingHUD(title: nil)
        
        api.request(.auth(alias: alias, email: email, password: password)) { [weak self] result in
            switch result {
            case let .success(response):
                if response.statusCode == 401 {
                    self?.continueButton.reset()
                    
                    let payload = try? JSONDecoder().decode(ErrorPayload.self, from: response.data)
                    switch payload?.reason {
                    case "email_busy":
                        self?.showErrorHUD(title: "auth_email_busy_error_title".localized)
                    case "alias_busy":
                        self?.showErrorHUD(title: "auth_alias_busy_error_title".localized)
                    case "wrong_password":
                        self?.showErrorHUD(title: "auth_wrong_password_error_title".localized)
                    default:
                        self?.showErrorHUD(title: "auth_401_error_title".localized)
                    }
                    
                    self?.hideHUD(after: 3)
                } else if response.statusCode == 200 {
                    User.shared.alias = alias
                    User.shared.email = email
                    User.shared.password = password
                    
                    if let userID = try? response.map(UserEntity.self).id {
                        Amplitude.instance().setUserId("\(userID)")
                    }
                    
                    self?.onFinish?()
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
        
        Analytics.logButtonTap(title: continueButton.titleLabel.text ?? "", screen: .auth)
    }
    
    @objc private func onTapAuthProblemsButton() {
        present(AuthProblemsScreen(email: email), animated: true, completion: nil)
        
        Analytics.logButtonTap(title: authProblemsButton.title, screen: .auth)
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
        containerView.addArrangedSubview(aliasField)
        containerView.addArrangedSubview(aliasHint)
        containerView.addArrangedSubview(emailField)
        containerView.addArrangedSubview(emailHint)
        containerView.addArrangedSubview(passwordField)
        containerView.addArrangedSubview(passwordHint)
        
        containerView.setCustomSpacing(32, after: titleLabel)
        containerView.setCustomSpacing(2, after: aliasField)
        containerView.setCustomSpacing(2, after: emailField)
        containerView.setCustomSpacing(2, after: passwordField)
        
        titleLabel.text = "auth_title".localized
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        aliasField.configure(model: .init(question: "auth_alias_title".localized, answer: nil))
        aliasField.setContentCompressionResistancePriority(.required, for: .vertical)
        aliasField.highlight(isCorrect: nil, animated: false, animationDuration: 0)
        aliasField.onChangeAnswer = { [unowned self] answer in
            self.alias = answer
            self.updateContinueButtonState()
            self.aliasField.highlight(isCorrect: !answer.isEmpty, animated: false, animationDuration: 0)
        }
        
        aliasHint.font = .text5
        aliasHint.textColor = .darkGray
        aliasHint.numberOfLines = 0
        aliasHint.text = "auth_alias_hint".localized
        aliasHint.setContentCompressionResistancePriority(.required, for: .vertical)
        
        emailField.keyboardType = .emailAddress
        emailField.configure(model: .init(question: "auth_email_title".localized, answer: nil))
        emailField.setContentCompressionResistancePriority(.required, for: .vertical)
        emailField.highlight(isCorrect: nil, animated: false, animationDuration: 0)
        emailField.onChangeAnswer = { [unowned self] answer in
            self.email = answer
            self.updateContinueButtonState()
            self.emailField.highlight(isCorrect: self.isValidEmail(answer), animated: false, animationDuration: 0)
        }
        
        emailHint.font = .text5
        emailHint.textColor = .darkGray
        emailHint.numberOfLines = 0
        emailHint.text = "auth_email_hint".localized
        emailHint.setContentCompressionResistancePriority(.required, for: .vertical)
        
        passwordField.answerField.textField.isSecureTextEntry = true
        passwordField.answerField.textField.textContentType = .password
        passwordField.configure(model: .init(question: "auth_password_title".localized, answer: nil))
        passwordField.setContentCompressionResistancePriority(.required, for: .vertical)
        passwordField.highlight(isCorrect: nil, animated: false, animationDuration: 0)
        passwordField.onChangeAnswer = { [unowned self] answer in
            self.password = answer
            self.updateContinueButtonState()
            self.passwordField.highlight(isCorrect: answer.count > 5, animated: false, animationDuration: 0)
        }
        
        passwordHint.font = .text5
        passwordHint.textColor = .darkGray
        passwordHint.numberOfLines = 0
        passwordHint.text = "auth_password_hint".localized
        passwordHint.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Auth problems button
        
        view.addSubview(authProblemsButton)
        
        authProblemsButton.isHidden = true
        authProblemsButton.heightConstraint?.constant = 0
        authProblemsButton.setTitleColor(.yellow, for: .normal)
        authProblemsButton.setTitleColor(.darkGray, for: .highlighted)
        authProblemsButton.setTitle("auth_problems_button_title".localized, for: .normal)
        authProblemsButton.addTarget(self, action: #selector(onTapAuthProblemsButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            authProblemsButton.topAnchor.constraint(greaterThanOrEqualTo: containerView.bottomAnchor, constant: 8),
            authProblemsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            authProblemsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
        ])
        
        // Continue button
        
        view.addSubview(continueButton)
        
        continueButton.isEnabled = false
        continueButton.titleLabel.text = "auth_continue_button_title".localized
        continueButton.onFill = { [unowned self] in
            self.auth()
            self.view.endEditing(true)
        }
        
        continueButtonBottomConstraint = continueButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -12
        )
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: authProblemsButton.bottomAnchor, constant: 12),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
            continueButtonBottomConstraint
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    private func updateContinueButtonState() {
        let aliasValid = alias?.isEmpty == false
        let emailValid = isValidEmail(email)
        let passwordValid = (password?.count ?? 0) > 5
        
        continueButton.isEnabled = aliasValid && emailValid && passwordValid
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
