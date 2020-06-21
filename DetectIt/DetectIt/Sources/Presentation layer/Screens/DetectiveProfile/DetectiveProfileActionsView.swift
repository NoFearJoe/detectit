//
//  DetectiveProfileActionsView.swift
//  DetectIt
//
//  Created by Илья Харабет on 20/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

final class DetectiveProfileActionsView: UIView {
    
    var onTapLeaderboardButton: (() -> Void)?
    var onTapLogoutButton: (() -> Void)?
    
    private let contentView = UIStackView()
    
    private let leaderboardActionButton = ActionButton(
        icon: UIImage.asset(named: "cup")!,
        title: "Таблица лидеров".localized,
        color: .lightGray
    )
    private let logoutActionButton = ActionButton(
        icon: UIImage.asset(named: "exit")!,
        title: "Выйти".localized,
        color: .lightGray
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentView)
        contentView.axis = .horizontal
        contentView.spacing = 28
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        contentView.addArrangedSubview(leaderboardActionButton)
        contentView.addArrangedSubview(logoutActionButton)
        
        leaderboardActionButton.onTap = { [unowned self] in
            self.onTapLeaderboardButton?()
        }
        
        logoutActionButton.onTap = { [unowned self] in
            self.onTapLogoutButton?()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

private final class ActionButton: UIView {
    
    var onTap: (() -> Void)?
    
    private let button = SolidButton()
    private let titleLabel = UILabel()
    
    init(icon: UIImage, title: String, color: UIColor) {
        super.init(frame: .zero)
        
        widthAnchor.constraint(lessThanOrEqualToConstant: 80).isActive = true
        
        addSubview(button)
        button.fill = .color(.darkGray)
        button.tintColor = color
        button.layer.cornerRadius = 24
        button.clipsToBounds = true
        button.setImage(icon, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 48),
            button.heightAnchor.constraint(equalToConstant: 48),
            button.topAnchor.constraint(equalTo: topAnchor),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            {
                let leading = button.leadingAnchor.constraint(equalTo: leadingAnchor)
                leading.priority = .defaultLow
                return leading
            }()
        ])
    
        addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.font = .text5
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTap() {
        onTap?()
    }
    
}
