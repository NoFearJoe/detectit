//
//  MainScreenTaskCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 27/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

public final class MainScreenTaskCell: UICollectionViewCell, TouchAnimatable {
    
    public static let identifier = String(describing: MainScreenTaskCell.self)
        
    // MARK: - Subviews
    
    private let backgroundImageView = UIImageView()
    
    private let topContainerView = UIView()
    private let taskKindLabel = UILabel()
    private let difficultyView = UIImageView()
        
    private let bottomContainerView = UIView()
    private let bottomBlurView = BlurView(style: .systemMaterialDark)
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let scoreLabel = UILabel()
    
    private var constraintBetweenTitleAndScore: NSLayoutConstraint!
    private var constraintBetweenTitleAndDescription: NSLayoutConstraint!
    
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
        public let kind: String
        public let title: String
        public let description: String
        public let difficultyIcon: UIImage
        public let score: String?
        public let scoreColor: UIColor
        
        var isSolved: Bool {
            score != nil
        }
        
        public init(backgroundImagePath: String?,
                    kind: String,
                    title: String,
                    description: String,
                    difficultyIcon: UIImage,
                    score: String?,
                    scoreColor: UIColor) {
            self.backgroundImagePath = backgroundImagePath
            self.kind = kind
            self.title = title
            self.description = description
            self.difficultyIcon = difficultyIcon
            self.score = score
            self.scoreColor = scoreColor
        }
        
    }
    
    func configure(model: Model, forSizeCalculation: Bool = false) {
        if !forSizeCalculation {
            if let imagePath = model.backgroundImagePath {
                backgroundImageView.loadImage(.staticAPI(imagePath)) { [weak self] image, cached in
                    self?.bottomBlurView.setHidden(image == nil, duration: cached ? 0 : 0.25)
                }
                taskKindLabel.configureShadow(radius: 2, isVisible: true)
            } else {
                backgroundImageView.image = nil
                taskKindLabel.configureShadow(radius: 2, isVisible: false)
            }
            
            bottomBlurView.isHidden = backgroundImageView.image == nil
        }
        
        taskKindLabel.text = model.kind.uppercased()
        difficultyView.image = model.difficultyIcon
                
        if model.isSolved {
            titleLabel.attributedText = model.title.strikethroughAttributedString(color: .white)
        } else {
            titleLabel.attributedText = NSAttributedString(string: model.title)
        }
        descriptionLabel.text = model.isSolved ? nil : model.description
        
        scoreLabel.text = model.score
        scoreLabel.textColor = model.scoreColor
        
        constraintBetweenTitleAndScore.constant = model.score == nil ? 0 : 12
        constraintBetweenTitleAndDescription.constant = model.description.isEmpty || model.isSolved ? 0 : 12
        
        if !forSizeCalculation {
            [titleLabel, taskKindLabel, descriptionLabel, difficultyView].forEach {
                $0.alpha = model.isSolved ? 0.5 : 1
            }
        }
    }
    
    func calculateSize(model: Model, width: CGFloat) -> CGSize {
        configure(model: model, forSizeCalculation: true)
        
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
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.clipsToBounds = true
        
        enableTouchAnimation()
    }
    
    private func setupViews() {
        contentView.addSubview(backgroundImageView)
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.cornerRadius = Constants.cornerRadius
        backgroundImageView.clipsToBounds = true
        
        backgroundImageView.pin(to: contentView)
        
        // MARK: Top container
        
        contentView.addSubview(topContainerView)
        
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // MARK: Task kind
        
        topContainerView.addSubview(taskKindLabel)
        
        taskKindLabel.font = .text4
        taskKindLabel.textColor = .lightGray
        taskKindLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        taskKindLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            taskKindLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: Constants.hInset),
            taskKindLabel.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor)
        ])
        
        // MARK: Difficulty
        
        topContainerView.addSubview(difficultyView)
        
        difficultyView.tintColor = .yellow
        difficultyView.contentMode = .scaleAspectFit
        difficultyView.setContentHuggingPriority(.required, for: .horizontal)
        difficultyView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        difficultyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            difficultyView.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            difficultyView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -Constants.hInset),
            difficultyView.leadingAnchor.constraint(equalTo: taskKindLabel.trailingAnchor, constant: 8),
            difficultyView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        // MARK: Bottom container
        
        contentView.addSubview(bottomContainerView)
        
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomContainerView.topAnchor.constraint(greaterThanOrEqualTo: topContainerView.bottomAnchor),
            bottomContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        bottomContainerView.addSubview(bottomBlurView)
        
        bottomBlurView.blurRadius = 20
        bottomBlurView.colorTint = .darkBackground
        bottomBlurView.colorTintAlpha = 0.8
        
        bottomBlurView.calculateFrame(container: bottomContainerView) { $0 }
        
        // MARK: Title
        
        bottomContainerView.addSubview(titleLabel)
        
        titleLabel.font = .heading4
        titleLabel.textColor = Constants.tintColor
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: Constants.hInset),
        ])
        
        // MARK: Score
        
        bottomContainerView.addSubview(scoreLabel)
        
        scoreLabel.font = .score2
        scoreLabel.textAlignment = .right
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        constraintBetweenTitleAndScore = scoreLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12)
        NSLayoutConstraint.activate([
            scoreLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            constraintBetweenTitleAndScore,
            scoreLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -Constants.hInset)
        ])
        
        // MARK: Description
        
        bottomContainerView.addSubview(descriptionLabel)
        
        descriptionLabel.font = .text4
        descriptionLabel.textColor = Constants.tintColor
        descriptionLabel.numberOfLines = 5
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        constraintBetweenTitleAndDescription = descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12)
        NSLayoutConstraint.activate([
            constraintBetweenTitleAndDescription,
            descriptionLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: Constants.hInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -Constants.hInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -12)
        ])
    }
    
}

private struct Constants {
    static let cornerRadius = CGFloat(16)
    static let hInset = CGFloat(12)
    static let tintColor = UIColor.white
}

