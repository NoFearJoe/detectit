//
//  FullVersionPurchaseScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 12/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class FullVersionPurchaseScreen: Screen {
    
    private let closeButton = SolidButton.closeButton()
    
    private let titleLabel = UILabel()
    private let featuresListView = UIStackView()
    private let disclaimerLabel = UILabel()
    private let buyButton = SolidButton.primaryButton()
    private let restoreButton = SolidButton.makePushButton()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(.fullVersionPurchase)
    }
    
    @objc private func didTapCloseButton() {
        close()
    }
    
    @objc private func didTapBuyButton() {
        showLoadingHUD(title: nil)
        isModalInPresentation = true
        
        FullVersionManager.purchase { error in
            self.updateBuyButton()
            
            self.isModalInPresentation = false
            
            if let error = error {
                self.showErrorHUD(title: error.localizedDescription)
                self.hideHUD(after: 2)
            } else {
                self.showSuccessHUD()
                
                self.logPurchase()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.close()
                }
            }
        }
        
        Analytics.logButtonTap(title: buyButton.title, screen: .fullVersionPurchase)
    }
    
    @objc private func didTapRestoreButton() {
        showLoadingHUD(title: nil)
        isModalInPresentation = true
        
        FullVersionManager.restorePurchases { success in
            self.isModalInPresentation = false
            
            if !success {
                self.showErrorHUD(title: "unknown_error_message".localized)
                self.hideHUD(after: 2)
            } else {
                self.showSuccessHUD()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.close()
                }
            }
        }
        
        Analytics.logButtonTap(title: restoreButton.title, screen: .fullVersionPurchase)
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        view.addSubview(titleLabel)
        
        titleLabel.font = UIFont.heading1.withSize(31)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.text = "pro_status_title".localized
        
        view.addSubview(featuresListView)
        
        featuresListView.axis = .vertical
        featuresListView.distribution = .fill
        
        featuresListView.addArrangedSubview(
            FeatureView(
                title: "pro_status_feature_1".localized,
                icon: UIImage.asset(named: "ThreeStars")?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
            )
        )
        featuresListView.addArrangedSubview(
            FeatureView(
                title: "pro_status_feature_2".localized,
                icon: UIImage.asset(named: "Nightmare")
            )
        )
        featuresListView.addArrangedSubview(
            FeatureView(
                title: "pro_status_feature_3".localized,
                icon: UIImage.asset(named: "key")
            )
        )
        featuresListView.addArrangedSubview(
            FeatureView(
                title: "pro_status_feature_4".localized,
                icon: UIImage.asset(named: "book")?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
            )
        )
        
        view.addSubview(disclaimerLabel)
        
        disclaimerLabel.font = .text5
        disclaimerLabel.textColor = .lightGray
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.text = "pro_status_disclaimer".localized
        
        view.addSubview(buyButton)
        updateBuyButton()
        
        buyButton.addTarget(self, action: #selector(didTapBuyButton), for: .touchUpInside)
        
        view.addSubview(restoreButton)
        restoreButton.setTitle("pro_status_restore".localized, for: .normal)
        
        restoreButton.addTarget(self, action: #selector(didTapRestoreButton), for: .touchUpInside)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
        ])
        
        featuresListView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            featuresListView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            featuresListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            featuresListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
        ])
        
        disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            disclaimerLabel.topAnchor.constraint(greaterThanOrEqualTo: featuresListView.bottomAnchor, constant: 12),
            disclaimerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            disclaimerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
        ])
        
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buyButton.topAnchor.constraint(equalTo: disclaimerLabel.bottomAnchor, constant: 8),
            buyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            buyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
        ])
        
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restoreButton.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: 8),
            restoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            restoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
            restoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
    
    private func updateBuyButton() {
        if let price = FullVersionManager.price, FullVersionManager.canBuy {
            buyButton.setTitle("pro_status_buy".localized + price, for: .normal)
        } else {
            buyButton.isEnabled = false
            buyButton.setTitle("buy_button_title".localized, for: .normal)
        }
    }
    
    private func subscribeToFullVersionStatusChange() {
        FullVersionManager.subscribeToProductInfoLoading(self) {
            self.updateBuyButton()
        }
    }
    
    private func close() {
        let delegate = self.presentationController?.delegate
        dismiss(animated: true) {
            delegate?.presentationControllerDidDismiss?(self.presentationController!)
        }
    }
    
    private func logPurchase() {
        guard let price = FullVersionManager.priceValue else { return }
        
        Analytics.logRevenue(price: price, productID: FullVersionManager.productID)
    }
    
}

private final class FeatureView: UIView {
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    init(title: String, icon: UIImage?) {
        super.init(frame: .zero)
        
        heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        iconView.image = icon
        iconView.contentMode = .center
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 42),
            iconView.heightAnchor.constraint(equalToConstant: 42),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        titleLabel.text = title
        titleLabel.font = .text3
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}
