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
    
    public var onTapProfileButton: (() -> Void)?
    
    private let containerView = UIStackView()
    private let aliasLabel = UILabel()
    private let rankLabel = UILabel()
    private let profileButton = SolidButton()
    
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
    
    @objc private func didTapProfileButton() {
        onTapProfileButton?()
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
        
        profileButton.fill = .gradient(
            startColor: .darkGray,
            endColor: .darkGray,
            startPosition: CGPoint(x: 0, y: 0),
            endPosition: CGPoint(x: 1, y: 1)
        )
        profileButton.layer.cornerRadius = 24
        profileButton.clipsToBounds = true
        profileButton.tintColor = .lightGray
        profileButton.setImage(UIImage.asset(named: "profile"), for: .normal)
        profileButton.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(profileButton)
        
        NSLayoutConstraint.activate([
            profileButton.widthAnchor.constraint(equalToConstant: 48),
            profileButton.heightAnchor.constraint(equalToConstant: 48),
            profileButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileButton.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
            profileButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
}
