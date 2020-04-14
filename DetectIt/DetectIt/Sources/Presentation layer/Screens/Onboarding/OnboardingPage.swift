//
//  OnboardingPage.swift
//  DetectIt
//
//  Created by Илья Харабет on 13/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

final class OnboardingPage: Screen {
    
    private let containerView = UIStackView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    func configure(icon: UIImage?, title: String, subtitle: String) {
        iconView.image = icon
        iconView.isHidden = icon == nil
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .black
        
        view.addSubview(containerView)
        
        containerView.axis = .vertical
        containerView.distribution = .fill
        containerView.alignment = .center
        containerView.spacing = 12
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20)
        ])
        
        containerView.addArrangedSubview(iconView)
        containerView.addArrangedSubview(titleLabel)
        containerView.addArrangedSubview(subtitleLabel)
        
        iconView.contentMode = .scaleAspectFit
        
        titleLabel.font = .heading2
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        subtitleLabel.font = .text3
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
    }
    
}
