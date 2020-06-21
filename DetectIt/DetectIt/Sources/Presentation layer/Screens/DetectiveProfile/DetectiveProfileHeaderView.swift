//
//  DetectiveProfileHeaderView.swift
//  DetectIt
//
//  Created by Илья Харабет on 21/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

final class DetectiveProfileHeaderView: UIView {
    
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
    
    private func setupViews() {
        addSubview(containerView)
        
        containerView.axis = .vertical
        containerView.distribution = .fill
        containerView.spacing = 0
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
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
