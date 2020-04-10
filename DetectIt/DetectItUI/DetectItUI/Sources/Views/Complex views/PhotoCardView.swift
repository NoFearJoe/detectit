//
//  PhotoCardView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 28/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class PhotoCardView: UIView {
    
    // MARK: - Model
    
    public struct Model {
        public let photo: UIImage
        public let title: String
        
        public init(photo: UIImage, title: String) {
            self.photo = photo
            self.title = title
        }
    }
    
    public var photo: UIImage? {
        didSet {
            photoView.image = photo
        }
    }
    
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    // MARK: - Subviews
    
    private let photoView = UIImageView()
    let titleLabel = UILabel()
    
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
        photo = model.photo
        title = model.title
    }
    
    // MARK: - Setup
    
    private func setupView() {
        layer.allowsEdgeAntialiasing = true
        translatesAutoresizingMaskIntoConstraints = false
        
        layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        backgroundColor = .photo
    }
    
    private func setupViews() {
        addSubview(photoView)
        addSubview(titleLabel)
        
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFit
        photoView.layer.allowsEdgeAntialiasing = true
        
        titleLabel.numberOfLines = 0
        titleLabel.font = .text3
        titleLabel.textColor = .mainText
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            photoView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            photoView.heightAnchor.constraint(equalTo: photoView.widthAnchor, multiplier: 10/15)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
}
