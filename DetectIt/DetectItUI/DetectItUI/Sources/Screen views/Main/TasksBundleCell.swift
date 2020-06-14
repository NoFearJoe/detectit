//
//  TasksBundleCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

public final class TasksBundleCell: UICollectionViewCell, TouchAnimatable {
    
    public static let identifier = String(describing: TasksBundleCell.self)
    
    public var onTapPlayButton: (() -> Void)?
    public var onTapBuyButton: (() -> Void)?
    
    // MARK: - Subviews
    
    private let backgroundImageView = UIImageView()
    
    /// Надпись "Набор" сверху.
    private let kindLabel = UILabel()
    
    /// Название набора.
    private let titleLabel = UILabel()
    
    private let bottomContainerView = UIView()
    private let bottomBlurView = BlurView(style: .systemMaterialDark)
    
    private let descriptionLabel = UILabel()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        
        public let backgroundImagePath: String?
        public let title: String
        public let description: String
        
        public init(backgroundImagePath: String?,
                    title: String,
                    description: String) {
            self.backgroundImagePath = backgroundImagePath
            self.title = title
            self.description = description
        }
        
    }
    
    func configure(model: Model, forSizeCalculation: Bool = false) {
        if let imagePath = model.backgroundImagePath {
            backgroundImageView.loadImage(.staticAPI(imagePath)) { [weak self] image, cached in
                self?.bottomBlurView.setHidden(image == nil, duration: cached ? 0 : 0.25)
            }
            kindLabel.configureShadow(radius: 2, isVisible: true)
            titleLabel.configureShadow(radius: 8, isVisible: true)
        } else {
            backgroundImageView.image = nil
            kindLabel.configureShadow(radius: 2, isVisible: false)
            titleLabel.configureShadow(radius: 8, isVisible: false)
        }
        
        bottomBlurView.isHidden = backgroundImageView.image == nil
        
        titleLabel.text = model.title
        descriptionLabel.text = model.description
    }
    
    // MARK: - Actions
    
    @objc private func didTapPlayButton() {
        onTapPlayButton?()
    }
    
    // MARK: - Setup
    
    private func setup() {
        contentView.backgroundColor = .darkBackground
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.clipsToBounds = true
        
        enableTouchAnimation()
    }
    
    private func setupViews() {
        contentView.addSubview(backgroundImageView)
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.cornerRadius = Constants.cornerRadius
        backgroundImageView.clipsToBounds = true
        
        backgroundImageView.calculateFrame(container: contentView) { $0 }
        
        contentView.addSubview(kindLabel)
        
        kindLabel.text = "main_screen_tasks_bundle_cell_kind_title".localized.uppercased()
        kindLabel.font = .text4
        kindLabel.textColor = .lightGray
        kindLabel.layer.masksToBounds = false
        kindLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        kindLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            kindLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.hInset),
            kindLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.hInset),
            kindLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)
        ])
        
        contentView.addSubview(titleLabel)
        
        titleLabel.font = .heading1
        titleLabel.textColor = Constants.tintColor
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.hInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.hInset)
        ])
        
        contentView.addSubview(bottomContainerView)
        
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            bottomContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        bottomContainerView.addSubview(bottomBlurView)
        
        bottomBlurView.blurRadius = 20
        bottomBlurView.colorTint = .darkBackground
        bottomBlurView.colorTintAlpha = 0.8
        
        bottomBlurView.calculateFrame(container: bottomContainerView) { $0 }
        
        bottomContainerView.addSubview(descriptionLabel)
        
        descriptionLabel.font = .text4
        descriptionLabel.textColor = Constants.tintColor
        descriptionLabel.numberOfLines = 5
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: Constants.hInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -Constants.hInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -16)
        ])
    }
    
}

private struct Constants {
    static let cornerRadius = CGFloat(16)
    static let hInset = CGFloat(12)
    static let tintColor = UIColor.white
}
