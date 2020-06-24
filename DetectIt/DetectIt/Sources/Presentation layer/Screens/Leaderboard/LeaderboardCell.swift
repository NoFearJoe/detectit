//
//  LeaderboardCell.swift
//  DetectIt
//
//  Created by Илья Харабет on 22/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

final class LeaderboardCell: UICollectionViewCell {
    
    static let identifier = "LeaderboardCell"
    
    private let positionLabel = UILabel()
    private let aliasLabel = UILabel()
    
    private let statsContainer = UIStackView()
    private let correctAnswersPercentLabel = UILabel()
    private let totalScoreLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    struct Model {
        let position: String
        let positionColor: UIColor
        let alias: String
        let isCurrentUser: Bool
        let correctAnswersPercent: String
        let totalScore: String
    }
    
    func configure(model: Model) {
        positionLabel.text = model.position
        positionLabel.textColor = model.positionColor
        aliasLabel.text = model.alias
        correctAnswersPercentLabel.text = model.correctAnswersPercent
        totalScoreLabel.text = model.totalScore
        
        aliasLabel.font = model.isCurrentUser ? .text2Bold : .text2
        backgroundColor = model.isCurrentUser ? .darkBackground : .systemBackground
    }
    
    private func setupViews() {
        contentView.addSubview(positionLabel)
        contentView.addSubview(aliasLabel)
        contentView.addSubview(statsContainer)
        statsContainer.addArrangedSubview(correctAnswersPercentLabel)
        statsContainer.addArrangedSubview(totalScoreLabel)
        
        positionLabel.font = .text2
        positionLabel.textColor = .lightGray
        positionLabel.textAlignment = .right
        positionLabel.translatesAutoresizingMaskIntoConstraints = false
        positionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let positionLabelWidthConstraint = positionLabel.widthAnchor.constraint(equalToConstant: 32)
        positionLabelWidthConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            positionLabelWidthConstraint,
            positionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: .hInset),
            positionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        aliasLabel.font = .text2
        aliasLabel.textColor = .white
        aliasLabel.translatesAutoresizingMaskIntoConstraints = false
        aliasLabel.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        
        NSLayoutConstraint.activate([
            aliasLabel.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor, constant: 8),
            aliasLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        statsContainer.axis = .vertical
        statsContainer.spacing = 2
        statsContainer.alignment = .center
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
        statsContainer.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            statsContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statsContainer.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            statsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -.hInset),
            statsContainer.leadingAnchor.constraint(greaterThanOrEqualTo: aliasLabel.trailingAnchor, constant: 8)
        ])
        
        correctAnswersPercentLabel.font = .score2
        correctAnswersPercentLabel.textColor = .yellow
        correctAnswersPercentLabel.setContentHuggingPriority(.required, for: .horizontal)
        correctAnswersPercentLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        totalScoreLabel.font = .text4
        totalScoreLabel.textColor = .white
        totalScoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        totalScoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
}
