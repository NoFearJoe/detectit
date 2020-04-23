//
//  TasksBundlePurchaseView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

final class TasksBundlePurchaseView: UIView {
    
    var onTapBuyButton: (() -> Void)?
    
    // MARK: - Subviews
    
    let priceLabel = UILabel()
    
    private let buyButton = SolidButton.makePushButton()
        
    private let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    func setLoading(_ isLoading: Bool) {
        buyButton.isHidden = isLoading
        priceLabel.isHidden = isLoading
        activityIndicator.isHidden = !isLoading
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    // MARK: - Actions
    
    @objc private func didTapBuyButton() {
        onTapBuyButton?()
    }
    
    // MARK: - Setup
    
    func setupViews() {
        heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        addSubview(buyButton)
        
        buyButton.setTitle("Купить", for: .normal) // TODO
        buyButton.setTitleColor(.black, for: .normal)
        buyButton.fill = .color(.yellow)
        buyButton.addTarget(self, action: #selector(didTapBuyButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            buyButton.topAnchor.constraint(equalTo: topAnchor),
            buyButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            buyButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(priceLabel)
        
        priceLabel.font = .text5
        priceLabel.textColor = .white
        priceLabel.textAlignment = .center
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: 2),
            priceLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(activityIndicator)
        
        activityIndicator.color = .lightGray
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
