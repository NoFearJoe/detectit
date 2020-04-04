//
//  TasksBundleScreenHeaderView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class TasksBundleScreenHeaderView: UIView {
    
    var onChangeHeight: ((CGFloat) -> Void)?
    
    // MARK: - Subviews
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let purchaseView = TasksBundlePurchaseView()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public struct Model {
        let image: UIImage
        let title: String
        let description: String
        let price: String?
        
        public init(image: UIImage,
                    title: String,
                    description: String,
                    price: String?) {
            self.image = image
            self.title = title
            self.description = description
            self.price = price
        }
    }
    
    func configure(model: Model) {
        imageView.image = model.image
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        purchaseView.setLoading(model.price == nil)
        purchaseView.priceLabel.text = model.price
    }
    
    // MARK: - Overrides
    
    public override var bounds: CGRect {
        didSet {
            onChangeHeight?(bounds.height)
        }
    }
    
    // MARK: - Setup
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupViews() {
        addSubview(imageView)
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(titleLabel)
        
        titleLabel.font = .bold(32)
        titleLabel.textColor = Constants.tintColor
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.hInset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.hInset),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -Constants.vOffset)
        ])
        
        addSubview(descriptionLabel)
        
        descriptionLabel.font = .regular(14)
        descriptionLabel.textColor = Constants.tintColor
        descriptionLabel.numberOfLines = 0
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.vOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.hInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.hInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.vOffset)
        ])
    }
    
}

private struct Constants {
    static let hInset = CGFloat(20)
    static let vOffset = CGFloat(20)
    static let tintColor = UIColor.white
}
