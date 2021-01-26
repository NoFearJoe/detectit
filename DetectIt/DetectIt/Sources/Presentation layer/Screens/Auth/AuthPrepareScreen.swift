//
//  AuthPrepareScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 07/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore
import SafariServices

final class AuthPrepareScreen: Screen {
    
    var onContinue: (() -> Void)?
    
    private let containerView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let privacyPolicyButton = SolidButton.makePushButton()
    private let continueButton = SolidButton.primaryButton()
    
    override func prepare() {
        super.prepare()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(.authPrepare)
    }
    
    @objc private func onTapPrivacyButton() {
        guard let url = URL(string: "https://detect-api.herokuapp.com/PrivacyPolicy.pdf") else { return }
        
        let safari = SFSafariViewController(url: url)
        
        present(safari, animated: true, completion: nil)
        
        Analytics.logButtonTap(title: privacyPolicyButton.title, screen: .authPrepare)
    }
    
    @objc private func onTapContinueButton() {
        onContinue?()
        
        Analytics.logButtonTap(title: continueButton.title, screen: .authPrepare)
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
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
        containerView.addArrangedSubview(subtitleLabel)
        
        containerView.setCustomSpacing(48, after: titleLabel)
        
        titleLabel.text = "auth_prepare_title".localized
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        subtitleLabel.text = "auth_prepare_subtitle".localized
        subtitleLabel.font = .text2
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        
        privacyPolicyButton.setTitleColor(.yellow, for: .normal)
        privacyPolicyButton.setTitleColor(.darkGray, for: .highlighted)
        privacyPolicyButton.setTitle("auth_prepare_privacy_policy_button".localized, for: .normal)
        privacyPolicyButton.addTarget(self, action: #selector(onTapPrivacyButton), for: .touchUpInside)
        
        view.addSubview(continueButton)
        
        continueButton.fill = .color(.lightGray)
        continueButton.setTitle("auth_prepare_continue_button_title".localized, for: .normal)
        continueButton.addTarget(self, action: #selector(onTapContinueButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        view.addSubview(privacyPolicyButton)

        NSLayoutConstraint.activate([
            privacyPolicyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            privacyPolicyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
            privacyPolicyButton.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -12)
        ])
    }
    
}
