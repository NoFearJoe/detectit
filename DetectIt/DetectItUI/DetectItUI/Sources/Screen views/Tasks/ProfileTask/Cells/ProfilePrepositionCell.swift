//
//  ProfilePrepositionCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 31/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfilePrepositionCell: AutosizingCollectionViewCell {
    
    public static let identifier = String(describing: ProfilePrepositionCell.self)
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
        
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        public let title: String
        public let text: String
        
        public init(title: String, text: String) {
            self.title = title
            self.text = text
        }
    }
    
    public func configure(model: Model) {
        titleLabel.text = model.title
        textLabel.attributedText = model.text.readableAttributedText(font: .text3)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        contentView.addSubview(textLabel)
        
        textLabel.font = .text3
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
}
