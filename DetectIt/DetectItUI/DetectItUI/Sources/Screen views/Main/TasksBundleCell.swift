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
    
    private let playStateViewsContainer = UIView()
    private let priceOrScoreLabel = UILabel()
    private let priceLoadingIndicator = UIActivityIndicatorView()
    
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
    
    public struct ShallowModel {
        
        public enum PlayState {
            case playable(score: String)
            case paid(price: String)
            case loading
        }
        
        public let playState: PlayState
        
        public init(playState: PlayState) {
            self.playState = playState
        }
        
    }
    
    func configure(model: Model, forSizeCalculation: Bool = false) {
        if let imagePath = model.backgroundImagePath {
            backgroundImageView.loadImage(.staticAPI(imagePath)) { [weak self] image in
                self?.bottomBlurView.setHidden(image == nil, duration: 0.25)
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
    
    func configure(model: ShallowModel) {
        switch model.playState {
        case let .playable(score):
            priceOrScoreLabel.text = score
            priceOrScoreLabel.isHidden = false
            priceLoadingIndicator.isHidden = true
        case let .paid(price):
            priceOrScoreLabel.text = price
            priceOrScoreLabel.isHidden = false
            priceLoadingIndicator.stopAnimating()
            priceLoadingIndicator.isHidden = true
        case .loading:
            priceOrScoreLabel.isHidden = true
            priceLoadingIndicator.startAnimating()
            priceLoadingIndicator.isHidden = false
        }
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
        
        let descriptionLabelBottomConstraint = descriptionLabel.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -16)
        descriptionLabelBottomConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: Constants.hInset),
            descriptionLabelBottomConstraint
        ])
        
        bottomContainerView.addSubview(playStateViewsContainer)
        
        playStateViewsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playStateViewsContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 36),
            playStateViewsContainer.topAnchor.constraint(greaterThanOrEqualTo: bottomContainerView.topAnchor, constant: 12),
            playStateViewsContainer.leadingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 12),
            playStateViewsContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -Constants.hInset),
            playStateViewsContainer.bottomAnchor.constraint(lessThanOrEqualTo: bottomContainerView.bottomAnchor, constant: -12),
            playStateViewsContainer.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor)
        ])
        
        playStateViewsContainer.addSubview(priceOrScoreLabel)
        
        priceOrScoreLabel.font = .score2
        priceOrScoreLabel.textColor = .yellow
        priceOrScoreLabel.textAlignment = .center
        priceOrScoreLabel.adjustsFontSizeToFitWidth = true
        priceOrScoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        priceOrScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceOrScoreLabel.centerYAnchor.constraint(equalTo: playStateViewsContainer.centerYAnchor),
            priceOrScoreLabel.leadingAnchor.constraint(equalTo: playStateViewsContainer.leadingAnchor),
            priceOrScoreLabel.trailingAnchor.constraint(equalTo: playStateViewsContainer.trailingAnchor)
        ])
        
        playStateViewsContainer.addSubview(priceLoadingIndicator)
        
        priceLoadingIndicator.color = .lightGray
        
        priceLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLoadingIndicator.centerXAnchor.constraint(equalTo: playStateViewsContainer.centerXAnchor),
            priceLoadingIndicator.centerYAnchor.constraint(equalTo: playStateViewsContainer.centerYAnchor)
        ])
    }
    
}

private struct Constants {
    static let cornerRadius = CGFloat(16)
    static let hInset = CGFloat(12)
    static let tintColor = UIColor.white
}
