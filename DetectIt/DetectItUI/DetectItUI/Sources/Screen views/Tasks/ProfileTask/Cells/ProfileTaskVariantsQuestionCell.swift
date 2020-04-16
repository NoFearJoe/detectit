//
//  ProfileTaskVariantsQuestionCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfileTaskVariantsQuestionCell: UIView {
        
    private let titleLabel = UILabel()
    private let variantsContainer = UIStackView()
    
    var selectedVariantView: AnswerVariantView? {
        (variantsContainer.arrangedSubviews as? [AnswerVariantView])?.first(where: { $0.isSelected })
    }
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        public let question: String
        public let variants: [String]
        public let selectedVariantIndex: Int?
        public let onSelectVariant: (Int) -> Void
        
        public init(question: String, variants: [String], selectedVariantIndex: Int?, onSelectVariant: @escaping (Int) -> Void) {
            self.question = question
            self.variants = variants
            self.selectedVariantIndex = selectedVariantIndex
            self.onSelectVariant = onSelectVariant
        }
    }
    
    func configure(model: Model) {
        titleLabel.text = model.question
        
        variantsContainer.arrangedSubviews.forEach {
            variantsContainer.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        model.variants.enumerated().forEach { index, variant in
            let view = makeVariantView(title: variant)
            view.isSelected = model.selectedVariantIndex == index
            view.onTap = { [unowned self] in
                self.updateSelectedVariant(index: index)
                model.onSelectVariant(index)
            }
            variantsContainer.addArrangedSubview(view)
        }
    }
    
    private func updateSelectedVariant(index: Int) {
        guard let variantViews = variantsContainer.arrangedSubviews as? [AnswerVariantView] else {
            return
        }
        
        variantViews.enumerated().forEach {
            $1.isSelected = $0 == index
        }
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        
        titleLabel.font = .heading4
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        addSubview(variantsContainer)
        
        variantsContainer.axis = .vertical
        variantsContainer.distribution = .fill
        variantsContainer.alignment = .fill
        
        variantsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            variantsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            variantsContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            variantsContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            variantsContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func makeVariantView(title: String) -> AnswerVariantView {
        let view = AnswerVariantView()
        
        view.titleLabel.text = title
        
        return view
    }
    
}
