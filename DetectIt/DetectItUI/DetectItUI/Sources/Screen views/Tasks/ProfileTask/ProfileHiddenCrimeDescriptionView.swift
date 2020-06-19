//
//  ProfileHiddenCrimeDescriptionView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 14/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfileHiddenCrimeDescriptionView: UIView {
    
    public var onTapGetStatusButton: (() -> Void)?
    
    private let messageLabel = UILabel()
    private let getStatusButton = SolidButton.makePushButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTapGetStatusButton() {
        onTapGetStatusButton?()
    }
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(messageLabel)
        messageLabel.text = "profile_task_screen_hidden_description_title".localized
        messageLabel.font = .text3
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(getStatusButton)
        getStatusButton.setTitleColor(.yellow, for: .normal)
        getStatusButton.setTitle("profile_task_screen_get_status_button_title".localized, for: .normal)
        getStatusButton.addTarget(self, action: #selector(didTapGetStatusButton), for: .touchUpInside)
        getStatusButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            getStatusButton.heightAnchor.constraint(equalToConstant: 40),
            getStatusButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            getStatusButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            getStatusButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            getStatusButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
