//
//  TitleAndToggleView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

public final class TitleAndToggleView: UIView {
    
    private var onToggle: ((Bool) -> Void)?
    
    private let titleLabel = UILabel()
    private let toggle = UISwitch()
    
    public init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didToggle() {
        onToggle?(toggle.isOn)
    }
    
    public func configure(title: String, onToggle: @escaping (Bool) -> Void) {
        titleLabel.text = title
        self.onToggle = onToggle
    }
    
    public var isOn: Bool? {
        didSet {
            toggle.isOn = isOn ?? false
            toggle.isEnabled = isOn != nil
        }
    }
    
    private func setup() {
        layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        addSubview(titleLabel)
        titleLabel.font = .text3
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
        
        addSubview(toggle)
        toggle.onTintColor = .yellow
        toggle.addTarget(self, action: #selector(didToggle), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toggle.topAnchor.constraint(equalTo: topAnchor),
            toggle.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            toggle.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
    }
    
}
