//
//  ProfileAttachmentCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfilePhotoAttachmentCell: AutosizingCollectionViewCell {
    
    var onTapPhoto: (() -> Void)?
    
    public static let identifier = String(describing: ProfilePhotoAttachmentCell.self)
    
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
    
    public typealias Model = PaperSheetWithPhotoView.Model
    
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
        containerView.setCustomSpacing(20, after: titleLabel)
        
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



//public final class ProfilePhotoAttachmentCell: AutosizingCollectionViewCell {
//
//    public static let identifier = String(describing: ProfilePhotoAttachmentCell.self)
//
//    // MARK: - Subviews
//
//    private let paperSheetView = PaperSheetWithPhotoView()
//
//    // MARK: - Init
//
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setupViews()
//    }
//
//    @available(*, unavailable)
//    public required init?(coder: NSCoder) { fatalError() }
//
//    // MARK: - Configuration
//
//    public typealias Model = PaperSheetWithPhotoView.Model
//
//    public func configure(model: Model) {
//        paperSheetView.configure(model: model)
//    }
//
//    // MARK: - Setup
//
//    func setupViews() {
//        contentView.addSubview(paperSheetView)
//
//        paperSheetView.configureShadow(
//            radius: 4,
//            opacity: 0.1,
//            color: .black,
//            offset: CGSize(width: 0, height: 2)
//        )
//
//        paperSheetView.pin(to: contentView)
//    }
//
//}
