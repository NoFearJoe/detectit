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
    
    public func configure(title: String, message: String?, onRetry: (() -> Void)?) {
        self.onRetry = onRetry
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.isHidden = message == nil
        retryButton.isHidden = onRetry == nil
    }
    
    public func setVisible(_ isVisible: Bool, animated: Bool) {
        superview?.bringSubviewToFront(self)
        
            alpha = isVisible ? 0 : 1
//            isHidden = false
        
        UIView.animate(
            withDuration: animated ? 0.5 : 0,
            animations: {
                self.alpha = isVisible ? 1 : 0
            }, completion: { _ in
                guard !isVisible else { return }
                
//                self.isHidden = true
            }
        )
    }
    
    private func setup() {
        backgroundColor = .black
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
    }
    
    @objc private func didTapRetryButton() {
        onRetry?()
    }
    
}
