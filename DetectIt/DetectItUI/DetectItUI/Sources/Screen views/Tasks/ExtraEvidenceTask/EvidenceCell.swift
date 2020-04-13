//
//  EvidenceCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 29/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

/// Ячейка, отображающая улику для "Выбора лишней улики".
public final class EvidenceCell: AutosizingCollectionViewCell {
    
    public var onLongTapPhoto: (() -> Void)?
    
    public static let identifier = String(describing: EvidenceCell.self)
    
    // MARK: - Subviews
    
    private let photoView = AutosizingImageView()
    private let titleLabel = UILabel()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        public let photo: UIImage
        public let title: String
        public let isSelected: Bool
        
        public init(photo: UIImage, title: String, isSelected: Bool) {
            self.photo = photo
            self.title = title
            self.isSelected = isSelected
        }
    }
    
    public func configure(model: Model) {
        photoView.image = model.photo
        titleLabel.text = model.title
        photoView.layer.borderWidth = model.isSelected ? 2 : 0
    }
    
    // MARK: - Setup
    
    private func setup() {
        layer.allowsEdgeAntialiasing = true
    }
    
    private func setupViews() {
        contentView.layoutMargins = .zero
        
        contentView.addSubview(photoView)
        contentView.addSubview(titleLabel)
        
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFit
        photoView.layer.allowsEdgeAntialiasing = true
        photoView.isUserInteractionEnabled = true
        photoView.layer.borderColor = UIColor.yellow.cgColor
        
        titleLabel.font = .text3
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            photoView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: photoView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongTapPhotoView))
        photoView.addGestureRecognizer(longTapRecognizer)
    }
    
    @objc private func didLongTapPhotoView() {
        onLongTapPhoto?()
    }
    
}
