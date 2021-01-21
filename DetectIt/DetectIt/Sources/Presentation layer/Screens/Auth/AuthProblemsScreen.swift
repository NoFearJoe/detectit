//
//  AuthProblemsScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 19.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import MessageUI
import DetectItUI

final class AuthProblemsScreen: Screen {
    
    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let writeToSupportButton = SolidButton.makePushButton()
    private let restorePasswordButton = SolidButton.primaryButton()
    
    private var email: String?
    
    init(email: String?) {
        self.email = email
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepare() {
        super.prepare()
                
        setupViews()
    }
    
    @objc private func onTapWriteToSupportButton() {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let viewController = MFMailComposeViewController()
        viewController.setPreferredSendingEmailAddress("mesterra.co@gmail.com")
        viewController.setToRecipients(["mesterra.co@gmail.com"])
        viewController.setSubject("report_problem_subject".localized)
        viewController.mailComposeDelegate = self
        
        present(viewController, animated: true, completion: nil)
    }
    
    @objc private func onTapRestorePasswordButton() {
        present(RestorePasswordScreen(email: email), animated: true, completion: nil)
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        // Title label
        
        view.addSubview(titleLabel)
        
        titleLabel.text = "auth_problems_title".localized
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset)
        ])
        
        // Text view
        
        view.addSubview(textView)
        
        textView.text = "auth_problems_text".localized
        textView.font = .text4
        textView.textColor = .white
        textView.isEditable = false
        textView.isSelectable = false
        textView.contentInset = .zero
        textView.bounces = false
        textView.alwaysBounceVertical = false
        textView.contentInsetAdjustmentBehavior = .never
        textView.showsVerticalScrollIndicator = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset)
        ])
        
        // Write to support button
        
        view.addSubview(writeToSupportButton)
        
        writeToSupportButton.setTitleColor(.yellow, for: .normal)
        writeToSupportButton.setTitleColor(.darkGray, for: .highlighted)
        writeToSupportButton.setTitle("auth_problems_write_to_support_button_title".localized, for: .normal)
        writeToSupportButton.addTarget(self, action: #selector(onTapWriteToSupportButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            writeToSupportButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            writeToSupportButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            writeToSupportButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
        ])
        
        // Restore password button
        
        view.addSubview(restorePasswordButton)
        
        restorePasswordButton.setTitle("auth_problems_restore_password_button_title".localized, for: .normal)
        restorePasswordButton.addTarget(self, action: #selector(onTapRestorePasswordButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            restorePasswordButton.topAnchor.constraint(equalTo: writeToSupportButton.bottomAnchor, constant: 8),
            restorePasswordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            restorePasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
            restorePasswordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
    
}

extension AuthProblemsScreen: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
