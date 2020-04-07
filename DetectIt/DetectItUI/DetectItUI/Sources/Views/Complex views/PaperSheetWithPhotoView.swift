//
//  PaperSheetWithPhotoView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class PaperSheetWithPhotoView: UIView {
    
    // MARK: - Model
    
    public struct Model {
        public let title: String
        public let photo: UIImage
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title?.uppercased()
        }
    }
    
    var photo: UIImage? {
        didSet {
            imageView.image = photo
        }
    }
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    
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
        title = model.title
        photo = model.photo
    }
    
    // MARK: - Setup
    
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layoutMargins = UIEdgeInsets(top: 32, left: 12, bottom: 32, right: 12)
        
        backgroundColor = .paper
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 30/21).isActive = true
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(imageView)
        
        titleLabel.font = .heading2
        titleLabel.textColor = .mainText
        titleLabel.numberOfLines = 0
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
}
