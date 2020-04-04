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
    
    // TODO: Add stack view
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()
    
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
        let icon: UIImage
        let title: String
        let score: String?
        let isEnabled: Bool
        
        public init(icon: UIImage,
                    title: String,
                    score: String?,
                    isEnabled: Bool) {
            self.icon = icon
            self.title = title
            self.score = score
            self.isEnabled = isEnabled
        }
    }
    
    func configure(model: Model) {
        iconView.image = model.icon
        titleLabel.text = model.title
        scoreLabel.text = model.score
        
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
        contentView.addSubview(iconView)
        
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFit
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
        ])
        
        contentView.addSubview(titleLabel)
        
        titleLabel.font = .regular(16)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12)
        ])
        
        contentView.addSubview(scoreLabel)
        
        scoreLabel.font = .bold(16)
        scoreLabel.textColor = .green
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            scoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            scoreLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 12),
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
    
}
