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
import JGProgressHUD

final class FullVersionPurchaseScreen: Screen {
    
    private let closeButton = SolidButton.closeButton()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let contributionContainer = UIStackView()
    private let contributionTitle = UILabel()
    private let contributionPicker = UISegmentedControl()
    private let contributionSubtitle = UILabel()
    
    private let buttonsContainer = UIStackView()
    private let contributionExplanationButton = SolidButton.makePushButton()
    private let buyButton = SolidButton.primaryButton()
    private let restoreButton = SolidButton.makePushButton()
    
    private var selectedProduct: FullVersionManager.Product?
    
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
    
    @objc private func onChangeContributionAmount() {
        contributionSubtitle.text = "pro_status_price_\(contributionPicker.selectedSegmentIndex)_text".localized
        contributionSubtitle.isHidden = false
        
        selectedProduct = FullVersionManager.Product.allCases.item(at: contributionPicker.selectedSegmentIndex)
        
        updateBuyButton()
    }
    
    @objc private func didTapCloseButton() {
        close()
    }
    
    @objc private func didTapContributionExplanationButton() {
        let hud = JGProgressHUD.init(style: .dark)
        hud.textLabel.attributedText = "pro_status_why_should_i_pay_text".localized.readableAttributedText(font: .text4)
        hud.indicatorView = nil
        hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 16, opacity: 0.25)
        hud.interactionType = .blockAllTouches
        hud.show(in: view)
        
        hud.tapOnHUDViewBlock = { [unowned hud] _ in
            hud.dismiss()
        }
        hud.tapOutsideBlock = { [unowned hud] _ in
            hud.dismiss()
        }
    }
    
    @objc private func didTapBuyButton() {
        guard let product = selectedProduct else { return }
        
        showLoadingHUD(title: nil)
        isModalInPresentation = true
        
        FullVersionManager.purchase(product: product) { error in
            self.updateBuyButton()
            
            self.isModalInPresentation = false
            
            if let error = error {
                self.showErrorHUD(title: error.localizedDescription)
                self.hideHUD(after: 2)
            } else {
                self.showSuccessHUD()
                
                self.logPurchase(product: product)
                
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
        
        view.addSubview(subtitleLabel)
        
        subtitleLabel.attributedText = "pro_status_subtitle".localized.readableAttributedText(font: .text4)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.isUserInteractionEnabled = true
        subtitleLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapContributionExplanationButton)
            )
        )
        
        
        view.addSubview(contributionContainer)
        
        contributionContainer.addArrangedSubview(contributionTitle)
        contributionContainer.addArrangedSubview(contributionPicker)
        contributionContainer.addArrangedSubview(contributionSubtitle)
        contributionContainer.axis = .vertical
        contributionContainer.spacing = 8
        
        contributionTitle.font = UIFont.heading4
        contributionTitle.textColor = .white
        contributionTitle.text = "pro_status_contribution_title".localized
        
        contributionPicker.selectedSegmentTintColor = .yellow
        contributionPicker.tintColor = .black
        contributionPicker.backgroundColor = .darkGray
        contributionPicker.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        contributionPicker.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        contributionPicker.addTarget(self, action: #selector(onChangeContributionAmount), for: .valueChanged)
        updatePrices()
        
        contributionSubtitle.font = UIFont.text4
        contributionSubtitle.textColor = .lightGray
        contributionSubtitle.numberOfLines = 0
        contributionSubtitle.isHidden = true
        
        view.addSubview(buttonsContainer)
        buttonsContainer.addArrangedSubview(contributionExplanationButton)
        buttonsContainer.addArrangedSubview(buyButton)
        buttonsContainer.addArrangedSubview(restoreButton)
        buttonsContainer.axis = .vertical
        buttonsContainer.spacing = 8
        
        contributionExplanationButton.setTitle("pro_status_why_should_i_pay".localized, for: .normal)
        contributionExplanationButton.addTarget(self, action: #selector(didTapContributionExplanationButton), for: .touchUpInside)
        
        updateBuyButton()
        buyButton.setTitle("buy_button_title".localized, for: .normal)
        buyButton.addTarget(self, action: #selector(didTapBuyButton), for: .touchUpInside)
        
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
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset)
        ])
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset)
        ])
        
        contributionContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contributionContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            contributionContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            contributionContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset)
        ])
        
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsContainer.topAnchor.constraint(greaterThanOrEqualTo: contributionContainer.bottomAnchor, constant: 8),
            buttonsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .hInset),
            buttonsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.hInset),
            buttonsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
    
    private func updateBuyButton() {
        buyButton.isEnabled = selectedProduct != nil
    }
    
    private func updatePrices() {
        FullVersionManager.Product.allCases.enumerated().forEach {
            contributionPicker.insertSegment(withTitle: FullVersionManager.price(for: $1), at: $0, animated: false)
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
    
    private func logPurchase(product: FullVersionManager.Product) {
        guard let price = FullVersionManager.priceValue(for: product) else { return }
        
        Analytics.logRevenue(price: price, productID: product.id)
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
