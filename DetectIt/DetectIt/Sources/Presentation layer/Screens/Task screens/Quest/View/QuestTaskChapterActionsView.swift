//
//  QuestTaskChapterActionsView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 25.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

final class QuestTaskChapterActionsView: UIView {
    
    private let actionViewsContainer = UIStackView()
    
    var selectedActionView: AnswerButton? {
        (actionViewsContainer.arrangedSubviews as? [AnswerButton])?.first(where: { $0.isSelected })
    }
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        public let isActive: Bool
        public let actions: [String]
        public let selectedActionIndex: Int?
        public let onSelectAction: (Int) -> Void
        
        public init(isActive: Bool, actions: [String], selectedActionIndex: Int?, onSelectAction: @escaping (Int) -> Void) {
            self.isActive = isActive
            self.actions = actions
            self.selectedActionIndex = selectedActionIndex
            self.onSelectAction = onSelectAction
        }
    }
    
    func configure(model: Model) {
        actionViewsContainer.arrangedSubviews.forEach {
            actionViewsContainer.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        model.actions.enumerated().forEach { index, variant in
            let view = AnswerButton()
            view.titleLabel.text = variant
            view.setFilled(model.selectedActionIndex == index)
            view.isEnabled = model.isActive
            view.heightConstraint.isActive = false
            view.onFill = {
               model.onSelectAction(index)
            }
            actionViewsContainer.addArrangedSubview(view)
        }
    }
    
    private func setupViews() {
        addSubview(actionViewsContainer)
        
        actionViewsContainer.axis = .vertical
        actionViewsContainer.distribution = .fill
        actionViewsContainer.alignment = .fill
        actionViewsContainer.spacing = 8
        
        actionViewsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionViewsContainer.topAnchor.constraint(equalTo: topAnchor),
            actionViewsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionViewsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionViewsContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
