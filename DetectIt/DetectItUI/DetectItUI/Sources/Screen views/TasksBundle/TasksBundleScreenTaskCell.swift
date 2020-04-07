//
//  TasksBundleScreenTaskCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class TasksBundleScreenTaskCell: UICollectionViewCell {
    
    static let identifier = String(describing: TasksBundleScreenTaskCell.self)
    
    // MARK: - Subviews
    
    private let contentContainer = UIStackView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let difficultyView = UIImageView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        let icon: UIImage?
        let title: String
        let score: (value: String, color: UIColor)?
        let difficultyImage: UIImage?
        let isEnabled: Bool
        
        public init(icon: UIImage? = nil,
                    title: String,
                    score: (String, UIColor)?,
                    difficultyImage: UIImage?,
                    isEnabled: Bool) {
            self.icon = icon
            self.title = title
            self.score = score
            self.difficultyImage = difficultyImage
            self.isEnabled = isEnabled
        }
    }
    
    func configure(model: Model) {
        iconView.image = model.icon
        iconView.isHidden = model.icon == nil
        
        titleLabel.text = model.title
        
        scoreLabel.text = model.score?.value
        scoreLabel.textColor = model.score?.color
        scoreLabel.isHidden = model.score == nil
        
        difficultyView.image = model.difficultyImage
        difficultyView.isHidden = model.difficultyImage == nil
        
        iconView.alpha = model.isEnabled ? 1 : 0.75
        titleLabel.alpha = model.isEnabled ? 1 : 0.75
        
        isUserInteractionEnabled = model.isEnabled
    }
    
    // MARK: - Overrides
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: 0.05) {
            self.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.05) {
            self.contentView.backgroundColor = .clear
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: 0.05) {
            self.contentView.backgroundColor = .clear
        }
    }
    
    // MARK: - Setup
    
    func setup() {
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
    }
    
    func setupViews() {
        contentView.addSubview(contentContainer)
        
        contentContainer.axis = .horizontal
        contentContainer.distribution = .fill
        contentContainer.alignment = .center
        
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        contentContainer.addArrangedSubview(iconView)
        
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor)
        ])
        
        contentContainer.addArrangedSubview(titleLabel)
        
        titleLabel.font = .text3
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        contentContainer.addArrangedSubview(difficultyView)
        
        difficultyView.tintColor = .yellow
        difficultyView.contentMode = .center
        
        difficultyView.translatesAutoresizingMaskIntoConstraints = false
        difficultyView.setContentHuggingPriority(.required, for: .horizontal)
        difficultyView.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            difficultyView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        contentContainer.addArrangedSubview(scoreLabel)
        
        scoreLabel.font = .score2
        scoreLabel.textColor = .green
        scoreLabel.textAlignment = .right
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        contentContainer.setCustomSpacing(12, after: iconView)
        contentContainer.setCustomSpacing(8, after: titleLabel)
        contentContainer.setCustomSpacing(12, after: difficultyView)
    }
    
}
