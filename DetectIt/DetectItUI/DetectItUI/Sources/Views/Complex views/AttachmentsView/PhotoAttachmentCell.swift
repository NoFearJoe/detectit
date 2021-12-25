//
//  PhotoAttachmentCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class PhotoAttachmentCell: AutosizingCollectionViewCell {
    
    var onTapPhoto: (() -> Void)?
    
    public static let identifier = String(describing: PhotoAttachmentCell.self)
    
    // MARK: - Subviews
    
    private let containerView = UIStackView()
    private let titleLabel = UILabel()
    
    private let photoView = UIImageView()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        public let title: String
        public let photo: UIImage
        
        public init(title: String, photo: UIImage) {
            self.title = title
            self.photo = photo
        }
    }
    
    public func configure(model: Model) {
        titleLabel.text = model.title
        photoView.image = model.photo
        
        setupPhotoViewConstraints(image: model.photo)
    }
    
    // MARK: - Setup
    
    func setupViews() {
        contentView.addSubview(containerView)
        
        containerView.axis = .vertical
        containerView.alignment = .fill
        containerView.distribution = .fill
        
        containerView.pin(to: contentView)
        
        containerView.addArrangedSubview(titleLabel)
        containerView.setCustomSpacing(12, after: titleLabel)
        
        titleLabel.font = .heading3
        titleLabel.textColor = .lightGray
        titleLabel.numberOfLines = 0
        
        containerView.addArrangedSubview(photoView)
        
        photoView.isUserInteractionEnabled = true
        photoView.contentMode = .scaleAspectFit
        photoView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onTapPhotoView))
        )
    }
    
    @objc private func onTapPhotoView() {
        onTapPhoto?()
    }
    
    func setupPhotoViewConstraints(image: UIImage) {
        let ratio = bounds.size.width / image.size.width
        let height = image.size.height * ratio
        
        photoView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
}
