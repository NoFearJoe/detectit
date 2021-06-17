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
    private let taskKindView = TagView()
    private let taskRatingView = RatingView(maxRating: 5, size: .small)
    private let difficultyLabel = UILabel()
        
    private let bottomContainerView = UIView()
    private let bottomBlurView = BlurView(style: .systemMaterialDark)
    
    private let lockedTaskView = LockedTaskView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let scoreLabel = UILabel()
    
    private var constraintBetweenLockedViewAndDescription: NSLayoutConstraint!
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
        public let difficulty: String
        public let difficultyColor: UIColor
        public let score: String?
        public let scoreColor: UIColor
        public let rating: Double?
        public let isLocked: Bool
        
        public init(backgroundImagePath: String?,
                    kind: String,
                    title: String,
                    description: String,
                    difficulty: String,
                    difficultyColor: UIColor,
                    score: String?,
                    scoreColor: UIColor,
                    rating: Double?,
                    isLocked: Bool) {
            self.backgroundImagePath = backgroundImagePath
            self.kind = kind
            self.title = title
            self.description = description
            self.difficulty = difficulty
            self.difficultyColor = difficultyColor
            self.score = score
            self.scoreColor = scoreColor
            self.rating = rating
            self.isLocked = isLocked
        }
        
    }
    
    func configure(model: Model, forSizeCalculation: Bool = false) {
        if !forSizeCalculation {
            if let imagePath = model.backgroundImagePath {
                backgroundImageView.loadImage(.staticAPI(imagePath), completion: { [weak self] image, cached, animationDuration in
                    self?.bottomBlurView.setHidden(image == nil, duration: animationDuration)
                })
            } else {
                backgroundImageView.image = nil
            }
            
            bottomBlurView.isHidden = backgroundImageView.image == nil
        }
                
        taskKindView.title = model.kind.uppercased()
        taskRatingView.rating = model.rating ?? 0
        taskRatingView.isHidden = model.rating == nil
        difficultyLabel.text = model.difficulty
        difficultyLabel.textColor = model.difficultyColor
        
        lockedTaskView.isHidden = !model.isLocked
        constraintBetweenLockedViewAndDescription.constant = model.isLocked ? 12 : 0
                
        titleLabel.attributedText = NSAttributedString(string: model.title)
        
        descriptionLabel.text = model.description
        descriptionLabel.numberOfLines = model.backgroundImagePath == nil ? 5 : 3
        
        scoreLabel.text = model.score
        scoreLabel.textColor = model.scoreColor
        scoreLabel.isHidden = model.score == nil
        
        constraintBetweenTitleAndScore.constant = model.score == nil ? 0 : 12
        constraintBetweenTitleAndDescription.constant = model.description.isEmpty ? 0 : 12
        
        if !forSizeCalculation {
            [titleLabel, descriptionLabel].forEach {
                $0.alpha = model.isLocked ? 0.5 : 1
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
        
        topContainerView.addSubview(taskKindView)

        taskKindView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        taskKindView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            taskKindView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: Constants.hInset / 2),
            taskKindView.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor)
        ])
        
        // MARK: Task rating
        
        topContainerView.addSubview(taskRatingView)
        
        taskRatingView.tintColor = .yellow
        taskRatingView.backgroundColor = .lightGray
        taskRatingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            taskRatingView.leadingAnchor.constraint(equalTo: taskKindView.trailingAnchor, constant: 6),
            taskRatingView.centerYAnchor.constraint(equalTo: taskKindView.centerYAnchor)
        ])
        
        // MARK: Difficulty
        
        topContainerView.addSubview(difficultyLabel)
        
        difficultyLabel.font = .score3
        difficultyLabel.textColor = .white
        difficultyLabel.setContentHuggingPriority(.required, for: .horizontal)
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            difficultyLabel.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            difficultyLabel.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -Constants.hInset),
            difficultyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: taskRatingView.trailingAnchor, constant: 8)
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
        
        bottomBlurView.blurRadius = 4
        bottomBlurView.colorTint = UIColor.darkBackground.withAlphaComponent(0.5)
//        bottomBlurView.colorTintAlpha = 0.5
        
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
        ])
        
        // MARK: Locked task
        
        bottomContainerView.addSubview(lockedTaskView)
        
        constraintBetweenLockedViewAndDescription = lockedTaskView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6)
        NSLayoutConstraint.activate([
            constraintBetweenLockedViewAndDescription,
            lockedTaskView.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -12),
            lockedTaskView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: Constants.hInset),
            lockedTaskView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -Constants.hInset),
        ])
    }
    
}

private struct Constants {
    static let cornerRadius = CGFloat(16)
    static let hInset = CGFloat(12)
    static let tintColor = UIColor.white
}
