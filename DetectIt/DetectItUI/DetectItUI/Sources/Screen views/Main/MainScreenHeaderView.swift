//
//  MainScreenHeaderView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 15/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class MainScreenHeaderView: UICollectionReusableView {
    
    public static let identifier = String(describing: MainScreenHeaderView.self)
    
    public static let prototype = MainScreenHeaderView()
    
    private let containerView = UIStackView()
    private let aliasLabel = UILabel()
    private let rankLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        public let alias: String
        public let rank: String?
        
        public init(alias: String, rank: String?) {
            self.alias = alias
            self.rank = rank
        }
    }
    
    public func configure(model: Model) {
        aliasLabel.text = model.alias
        rankLabel.text = model.rank
        rankLabel.isHidden = model.rank == nil
    }
    
    public func size(model: Model, width: CGFloat) -> CGSize {
        configure(model: model)
        
        setNeedsLayout()
        layoutIfNeeded()
        
        return systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
    }
    
    private func setupViews() {
        addSubview(containerView)
        
        containerView.axis = .vertical
        containerView.distribution = .fill
        containerView.spacing = 0
        
        containerView.pin(to: self)
        
        containerView.addArrangedSubview(aliasLabel)
        containerView.addArrangedSubview(rankLabel)
        
        aliasLabel.font = .score1
        aliasLabel.textColor = .white
        aliasLabel.numberOfLines = 0
        
        rankLabel.font = .score2
        rankLabel.textColor = .yellow
        rankLabel.numberOfLines = 0
    }
    
}
