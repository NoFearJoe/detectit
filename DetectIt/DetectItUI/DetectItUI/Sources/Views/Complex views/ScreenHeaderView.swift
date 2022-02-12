//
//  ScreenHeaderView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 03.02.2022.
//  Copyright © 2022 Mesterra. All rights reserved.
//

import UIKit

public final class ScreenHeaderView: UIView {
    
    public var onClose: (() -> Void)?
    
    private var blurView = BlurView(style: .dark)
    
    public let closeButton = SolidButton.closeButton()
    public let titleLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTapCloseButton() {
        onClose?()
    }
    
    private func setupViews() {
        addSubview(blurView)
        blurView.blurRadius = 20
        blurView.colorTint = UIColor.black.withAlphaComponent(0.5)
        blurView.pin(to: self)
        
        addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -.hInset)
        ])
        
        addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        titleLabel.font = .heading3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .hInset),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: closeButton.topAnchor)
        ])
    }
    
}

