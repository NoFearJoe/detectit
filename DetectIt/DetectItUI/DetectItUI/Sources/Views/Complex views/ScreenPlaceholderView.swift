//
//  ScreenPlaceholderView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 29/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ScreenPlaceholderView: UIView {
    
    var onRetry: (() -> Void)?
    var onClose: (() -> Void)?
    
    private let closeButton = SolidButton.closeButton()
    private let contentView = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let retryButton = UIButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public func configure(title: String,
                          message: String?,
                          onRetry: (() -> Void)?,
                          onClose: (() -> Void)?) {
        self.onRetry = onRetry
        self.onClose = onClose
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.isHidden = message == nil
        retryButton.isHidden = onRetry == nil
        
        closeButton.isHidden = onClose == nil
    }
    
    public func setVisible(_ isVisible: Bool, animated: Bool) {
        superview?.bringSubviewToFront(self)
        
        alpha = isVisible ? 0 : 1
        
        UIView.animate(
            withDuration: animated ? 0.5 : 0,
            animations: {
                self.alpha = isVisible ? 1 : 0
            },
            completion: nil
        )
    }
    
    private func setup() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupViews() {
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20)
        ])
        
        contentView.axis = .vertical
        contentView.distribution = .fill
        contentView.alignment = .center
        
        contentView.addArrangedSubview(titleLabel)
        contentView.addArrangedSubview(messageLabel)
        contentView.addArrangedSubview(retryButton)
        
        contentView.setCustomSpacing(12, after: titleLabel)
        contentView.setCustomSpacing(40, after: messageLabel)
        
        titleLabel.font = .heading4
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        messageLabel.font = .text3
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        retryButton.titleLabel?.font = .text2
        retryButton.setTitleColor(.yellow, for: .normal)
        retryButton.setTitle("retry_button_title".localized, for: .normal)
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        retryButton.addTarget(self, action: #selector(didTapRetryButton), for: .touchUpInside)
        
        addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func didTapRetryButton() {
        onRetry?()
    }
    
    @objc private func didTapCloseButton() {
        onClose?()
    }
    
}
