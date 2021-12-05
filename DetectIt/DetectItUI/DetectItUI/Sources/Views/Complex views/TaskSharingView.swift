//
//  TaskSharingView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 18.06.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

public final class TaskSharingView: UIView, TouchAnimatable {
    
    public var onShare: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let shareIcon = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTap() {
        onShare?()
    }
    
    private func setup() {
        enableTouchAnimation()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        backgroundColor = .darkBackground
        
        layoutMargins = UIEdgeInsets(top: 16, left: .hInset, bottom: 16, right: .hInset)
        
        addSubview(titleLabel)
        titleLabel.text = "task_sharing_title".localized
        titleLabel.textColor = .white
        titleLabel.font = .text3
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(shareIcon)
        shareIcon.tintColor = .yellow
        shareIcon.image = UIImage.asset(named: "share")
        shareIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            shareIcon.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            shareIcon.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            shareIcon.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            shareIcon.widthAnchor.constraint(equalToConstant: 24),
            shareIcon.heightAnchor.constraint(equalTo: shareIcon.widthAnchor)
        ])
    }
    
}
