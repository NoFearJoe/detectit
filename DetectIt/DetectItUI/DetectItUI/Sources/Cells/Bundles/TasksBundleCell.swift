//
//  TasksBundleCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class TasksBundleCell: UICollectionViewCell, TouchAnimatable {
    
    public static let identifier = String(describing: TasksBundleCell.self)
    
    public var onTapPlayButton: (() -> Void)?
    public var onTapBuyButton: (() -> Void)?
    
    // MARK: - Subviews
    
    private let backgroundImageView = UIImageView()
    
    private let titleLabel = UILabel()
    
    private let bottomContainerView = UIView()
    private let bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
    
    private let descriptionLabel = UILabel()
    
    private let playStateViewsContainer = UIStackView()
    private let playButton = SolidButton.makePushButton()
    private let purchaseView = TasksBundlePurchaseView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        
        public enum PlayState {
            case playable
            case paid(price: String)
            case loading
        }
        
        public let backgroundImage: UIImage
        public let title: String
        public let description: String
        public let playState: PlayState
        
        public init(backgroundImage: UIImage,
                    title: String,
                    description: String,
                    playState: PlayState) {
            self.backgroundImage = backgroundImage
            self.title = title
            self.description = description
            self.playState = playState
        }
        
    }
    
    func configure(model: Model) {
        backgroundImageView.image = model.backgroundImage
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        
        switch model.playState {
        case .playable:
            playButton.isHidden = false
            purchaseView.isHidden = true
        case let .paid(price):
            playButton.isHidden = true
            purchaseView.isHidden = false
            purchaseView.setLoading(false)
            purchaseView.priceLabel.text = price
        case .loading:
            playButton.isHidden = true
            purchaseView.isHidden = false
            purchaseView.setLoading(true)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapPlayButton() {
        onTapPlayButton?()
    }
    
    // MARK: - Setup
    
    private func setup() {
        contentView.backgroundColor = .black
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.clipsToBounds = true
        
        configureShadow(radius: 24, opacity: 0.1, color: .black, offset: .zero)
        
        enableTouchAnimation()
    }
    
    private func setupViews() {
        contentView.addSubview(backgroundImageView)
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.cornerRadius = Constants.cornerRadius
        backgroundImageView.clipsToBounds = true
        
        backgroundImageView.pin(to: contentView)
        
        contentView.addSubview(titleLabel)
        
        titleLabel.font = .bold(32)
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
        
        bottomBlurView.pin(to: bottomContainerView)
        
        bottomContainerView.addSubview(descriptionLabel)
        
        descriptionLabel.font = .regular(14)
        descriptionLabel.textColor = Constants.tintColor
        descriptionLabel.numberOfLines = 0
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        let descriptionLabelBottomConstraint = descriptionLabel.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -12)
        descriptionLabelBottomConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: Constants.hInset),
            descriptionLabelBottomConstraint
        ])
        
        bottomContainerView.addSubview(playStateViewsContainer)
        
        playStateViewsContainer.axis = .vertical
        playStateViewsContainer.distribution = .fill
        
        playStateViewsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playStateViewsContainer.topAnchor.constraint(greaterThanOrEqualTo: bottomContainerView.topAnchor, constant: 8),
            playStateViewsContainer.leadingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 12),
            playStateViewsContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -Constants.hInset),
            playStateViewsContainer.bottomAnchor.constraint(lessThanOrEqualTo: bottomContainerView.bottomAnchor, constant: -8),
            playStateViewsContainer.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor)
        ])
        
        playStateViewsContainer.addArrangedSubview(playButton)
        
        playButton.setTitle("Играть", for: .normal) // TODO
        playButton.setTitleColor(.white, for: .normal)
        playButton.fill = .color(.systemBlue)
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        
        playStateViewsContainer.addArrangedSubview(purchaseView)
        
        purchaseView.translatesAutoresizingMaskIntoConstraints = false
        purchaseView.onTapBuyButton = { [unowned self] in
            self.onTapBuyButton?()
        }
    }
    
}

private struct Constants {
    static let cornerRadius = CGFloat(16)
    static let hInset = CGFloat(12)
    static let tintColor = UIColor.white
}
