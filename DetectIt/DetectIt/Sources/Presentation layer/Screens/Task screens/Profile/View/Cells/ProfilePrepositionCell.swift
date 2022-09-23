//
//  ProfilePrepositionCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 31/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public final class ProfilePrepositionCell: AutosizingCollectionViewCell {
    
    public static let identifier = String(describing: ProfilePrepositionCell.self)
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel()
    private let textView = TextView()
        
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
        public let text: String?
        
        public init(title: String, text: String?) {
            self.title = title
            self.text = text
        }
    }
    
    public func configure(model: Model) {
        titleLabel.text = model.title
        
        textView.attributedText = model.text?.readableAttributedText(font: .text3)
        textView.isHidden = model.text == nil || model.text!.isEmpty
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        let container = UIStackView(arrangedSubviews: [titleLabel, textView])
        container.axis = .vertical
        container.spacing = 20
        
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        titleLabel.font = .heading1
        titleLabel.textColor = .softWhite
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
}
