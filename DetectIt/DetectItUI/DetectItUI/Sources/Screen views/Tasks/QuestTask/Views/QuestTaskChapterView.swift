//
//  QuestTaskChapterView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 24.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class QuestTaskChapterView: UIView {
    
    // MARK: - Public actions
    
    public var onSelectAction: ((Int) -> Void)?
    
    // MARK: - Model
    
    public struct Model {
        public let title: String
        public let text: String
        public let isActive: Bool
        public let actions: [String]
        public let selectedActionIndex: Int?
        
        public init(title: String, text: String, isActive: Bool, actions: [String], selectedActionIndex: Int?) {
            self.title = title
            self.text = text
            self.isActive = isActive
            self.actions = actions
            self.selectedActionIndex = selectedActionIndex
        }
    }
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let actionsView = QuestTaskChapterActionsView()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public func configure(model: Model) {
        titleLabel.text = model.title
        textLabel.attributedText = model.text.readableAttributedText()
        
        actionsView.configure(
            model: QuestTaskChapterActionsView.Model(
                isActive: model.isActive,
                actions: model.actions,
                selectedActionIndex: model.selectedActionIndex,
                onSelectAction: { [unowned self] index in
                    self.onSelectAction?(index)
                }
            )
        )
    }
    
    // MARK: - Setup
    
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layoutMargins = .zero
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(actionsView)
        
        titleLabel.font = .heading3
        titleLabel.textColor = .lightGray
        titleLabel.numberOfLines = 0
        
        textLabel.font = .text3
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        
        actionsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionsView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20),
            actionsView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            actionsView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            actionsView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
}
