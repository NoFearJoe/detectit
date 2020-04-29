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
    
    private let titleLabel = UILabel()
    
    private let bottomContainerView = UIView()
    private let bottomBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
    
    private let descriptionLabel = UILabel()
    
    private let playStateViewsContainer = UIView()
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
            case playable
            case paid(price: String)
            case loading
        }
        
        public let playState: PlayState
        
        public init(playState: PlayState) {
            self.playState = playState
        }
        
    }
    
    func configure(model: Model) {
        if let imagePath = model.backgroundImagePath {
            ImageLoader.share.load(.staticAPI(imagePath)) { [weak self] image in
                self?.backgroundImageView.image = image
            }
        } else {
            backgroundImageView.image = nil
        }
        
        titleLabel.text = model.title
        descriptionLabel.text = model.description
    }
    
    func configure(model: ShallowModel) {
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
        
        enableTouchAnimation()
    }
    
    private func setupViews() {
        contentView.addSubview(backgroundImageView)
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.cornerRadius = Constants.cornerRadius
        backgroundImageView.clipsToBounds = true
        
        backgroundImageView.calculateFrame(container: contentView) { $0 }
        
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
            playStateViewsContainer.widthAnchor.constraint(equalToConstant: 96),
            playStateViewsContainer.topAnchor.constraint(greaterThanOrEqualTo: bottomContainerView.topAnchor, constant: 12),
            playStateViewsContainer.leadingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor, constant: 12),
            playStateViewsContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -Constants.hInset),
            playStateViewsContainer.bottomAnchor.constraint(lessThanOrEqualTo: bottomContainerView.bottomAnchor, constant: -12),
            playStateViewsContainer.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor)
        ])
        
        playStateViewsContainer.addSubview(playButton)
        
        playButton.setTitle("main_screen_tasks_bundle_cell_play_button_title".localized, for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.fill = .color(.systemBlue)
        playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        
        playButton.calculateFrame(container: playStateViewsContainer) { bounds -> CGRect in
            CGRect.centered(in: bounds, size: CGSize(width: bounds.width, height: 28))
        }
        
        playStateViewsContainer.addSubview(purchaseView)
        
        purchaseView.onTapBuyButton = { [unowned self] in
            self.onTapBuyButton?()
        }
        
        purchaseView.calculateFrame(container: playStateViewsContainer) { bounds -> CGRect in
            CGRect.centered(in: bounds, size: CGSize(width: bounds.width, height: 44))
        }
    }
    
}

private struct Constants {
    static let cornerRadius = CGFloat(16)
    static let hInset = CGFloat(12)
    static let tintColor = UIColor.white
}
