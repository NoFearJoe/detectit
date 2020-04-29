//
//  TasksBundleScreenHeaderView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

public final class TasksBundleScreenHeaderView: UIView {
    
    var onChangeHeight: ((CGFloat) -> Void)?
    var onTapBuyButton: (() -> Void)?
    
    // MARK: - Subviews
    
    private let imageView = UIImageView()
    private let imageGradientView = GradientView()
    private let titleLabel = UILabel()
    
    private let bottomViewsContainer = UIStackView()
    
    private let descriptionAndPurchaseViewsContainer = UIStackView()
    private let descriptionLabel = UILabel()
    private let purchaseView = TasksBundlePurchaseView()
    
    private let totalScoreLabel = UILabel()
    
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
        let image: String
        let title: String
        let totalScore: String
        let description: String
        
        let isPaid: Bool
        let price: String?
        
        public init(image: String,
                    title: String,
                    totalScore: String,
                    description: String,
                    isPaid: Bool,
                    price: String?) {
            self.image = image
            self.title = title
            self.totalScore = totalScore
            self.description = description
            self.isPaid = isPaid
            self.price = price
        }
    }
    
    func configure(model: Model) {
        ImageLoader.share.load(.staticAPI(model.image)) { [weak self] image in
            self?.imageView.image = image
        }
        
        titleLabel.text = model.title
        
        descriptionLabel.text = model.description
        
        purchaseView.isHidden = !model.isPaid
        purchaseView.setLoading(model.price == nil)
        purchaseView.priceLabel.text = model.price
        
        totalScoreLabel.isHidden = model.isPaid
        totalScoreLabel.attributedText = makeAttributedScoreString(score: model.totalScore)
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
        let heightMultiplier: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 9/16 : 5/16
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: heightMultiplier),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(imageGradientView)
        
        imageGradientView.startColor = UIColor.black.withAlphaComponent(0)
        imageGradientView.endColor = .black
        
        imageGradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageGradientView.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.5),
            imageGradientView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            imageGradientView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            imageGradientView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
        ])
        
        addSubview(titleLabel)
        
        titleLabel.font = .heading1
        titleLabel.textColor = Constants.tintColor
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.hInset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.hInset),
            titleLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -Constants.vOffset)
        ])
        
        addSubview(bottomViewsContainer)
        
        bottomViewsContainer.axis = .vertical
        bottomViewsContainer.distribution = .fillProportionally
        bottomViewsContainer.alignment = .fill
        bottomViewsContainer.spacing = Constants.vOffset
        
        bottomViewsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomViewsContainer.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.vOffset),
            bottomViewsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.hInset),
            bottomViewsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.hInset),
            bottomViewsContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.vOffset)
        ])
        
        bottomViewsContainer.addArrangedSubview(descriptionAndPurchaseViewsContainer)
        
        descriptionAndPurchaseViewsContainer.axis = .horizontal
        descriptionAndPurchaseViewsContainer.distribution = .fill
        descriptionAndPurchaseViewsContainer.alignment = .top
        descriptionAndPurchaseViewsContainer.spacing = 8
        
        descriptionAndPurchaseViewsContainer.addArrangedSubview(descriptionLabel)
        
        descriptionLabel.font = .text4
        descriptionLabel.textColor = Constants.tintColor
        descriptionLabel.numberOfLines = 0
        descriptionLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        descriptionLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        descriptionAndPurchaseViewsContainer.addArrangedSubview(purchaseView)
        
        purchaseView.setContentCompressionResistancePriority(.required, for: .horizontal)
        purchaseView.onTapBuyButton = { [unowned self] in
            self.onTapBuyButton?()
        }
        
        purchaseView.widthAnchor.constraint(equalToConstant: 96).isActive = true
        
        bottomViewsContainer.addArrangedSubview(totalScoreLabel)
        
        totalScoreLabel.font = .heading4
        totalScoreLabel.textColor = .yellow
    }
    
    private func makeAttributedScoreString(score: String) -> NSAttributedString {
        let resultString = NSMutableAttributedString()
        
        let prefixString = NSAttributedString(string: "Общий счет ", attributes: [.font: UIFont.text3, .foregroundColor: UIColor.lightGray])
        let scoreString = NSAttributedString(string: score, attributes: [.font: UIFont.heading4, .foregroundColor: UIColor.yellow])
        
        resultString.append(prefixString)
        resultString.append(scoreString)
        
        return resultString
    }
    
}

private struct Constants {
    static let hInset = CGFloat(20)
    static let vOffset = CGFloat(20)
    static let tintColor = UIColor.white
}
