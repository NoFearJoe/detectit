//
//  MainScreenBannerCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 01.02.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public final class MainScreenBannerCell: UICollectionViewCell, TouchAnimatable {
    
    static let identifier = String(describing: MainScreenBannerCell.self)
    
    var onTapCloseButton: (() -> Void)?
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton(type: .custom)
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        onTapCloseButton?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setup()
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        public let title: String
        public let subtitle: String
        
        public init(title: String,
                    subtitle: String) {
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    func configure(model: Model) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }
    
    func calculateSize(model: Model, width: CGFloat) -> CGSize {
        configure(model: model)
        
        setNeedsLayout()
        layoutIfNeeded()
        
        return contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
    }
    
    // MARK: - Setup
    
    private func setup() {
        contentView.backgroundColor = .darkBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        enableTouchAnimation()
    }
    
    private func setupViews() {
        // Title
        
        contentView.addSubview(titleLabel)
        titleLabel.font = .score2
        titleLabel.textColor = .yellow
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
        
        // Subtitle
        
        contentView.addSubview(subtitleLabel)
        subtitleLabel.font = .text4
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
        
        // Close button
        
        contentView.addSubview(closeButton)
        closeButton.tintColor = .lightGray
        closeButton.setImage(UIImage.asset(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
}
