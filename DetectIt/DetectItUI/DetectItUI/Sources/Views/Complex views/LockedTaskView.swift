//
//  LockedTaskView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 14/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class LockedTaskView: UIView {
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: 24)
    
    public override var isHidden: Bool {
        didSet {
            heightConstraint.constant = isHidden ? 0 : 24
        }
    }
    
    public init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint.isActive = true
        
        iconView.image = UIImage.asset(named: "lock")?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
        iconView.contentMode = .center
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        titleLabel.text = "pro_status_blocked_task_message".localized
        titleLabel.font = .text5
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
}
