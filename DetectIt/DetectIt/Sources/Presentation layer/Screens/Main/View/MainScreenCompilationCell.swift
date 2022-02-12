//
//  MainScreenCompilationCell.swift
//  DetectIt
//
//  Created by Илья Харабет on 31.01.2022.
//  Copyright © 2022 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public final class MainScreenCompilationCell: UICollectionViewCell, TouchAnimatable {
    
    public static let identifier = "MainScreenCompilationCell"
    
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        public let title: String
        public let imageUrl: String
    }
    
    public func configure(model: Model) {
        titleLabel.text = model.title
        backgroundImageView.loadImage(.staticAPI(model.imageUrl))
    }
    
    private func setup() {
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        
        contentView.addSubview(backgroundImageView)
        backgroundImageView.pin(to: contentView)
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.backgroundColor = .darkBackground
        
        titleLabel.textColor = .white
        titleLabel.font = .heading4
        titleLabel.numberOfLines = 3
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        enableTouchAnimation()
    }
    
}
