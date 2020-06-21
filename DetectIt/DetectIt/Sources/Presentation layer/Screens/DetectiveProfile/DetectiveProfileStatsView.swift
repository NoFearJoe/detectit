//
//  DetectiveProfileStatsView.swift
//  DetectIt
//
//  Created by Илья Харабет on 20/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

final class DetectiveProfileStatsView: UIView {
    
    let titleLabel = UILabel()
    let statsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutMargins = .zero
        
        titleLabel.font = .heading2
        titleLabel.textColor = .lightGray
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        
        statsLabel.font = .score1
        statsLabel.textColor = .yellow
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statsLabel)
        
        NSLayoutConstraint.activate([
            statsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            statsLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            statsLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            statsLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
