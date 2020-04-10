//
//  ListSectionHeaderView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

final class ListSectionHeaderView: UICollectionReusableView {
    
    static let identifier = String(describing: ListSectionHeaderView.self)
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTitleLabel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    private func setupTitleLabel() {
        layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        
        titleLabel.font = .heading3
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
    }
    
}
