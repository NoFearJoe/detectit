//
//  MainScreenFiltersView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 24/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class MainScreenFiltersView: UIScrollView {
    
    public var onSelectItem: ((Int) -> Void)?
        
    private let contentView = UIStackView()
    
    public init() {
        super.init(frame: .zero)
        
        clipsToBounds = false
        
        alwaysBounceHorizontal = true
        showsHorizontalScrollIndicator = false
        
        contentInset.top = 4
        contentInset.bottom = 4
        
        addSubview(contentView)
        contentView.pin(to: self)
        
        contentView.axis = .horizontal
        contentView.spacing = 12
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        public let title: String
        public let isSelected: Bool
        
        public init(title: String, isSelected: Bool) {
            self.title = title
            self.isSelected = isSelected
        }
    }
    
    public func configure(models: [Model]) {
        contentView.arrangedSubviews.forEach {
            contentView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        models.enumerated().forEach { index, model in
            let filterView = MainScreenFilterCell()
            filterView.configure(model: model)
            filterView.onTap = { [unowned self] in
                self.onSelectItem?(index)
            }
            contentView.addArrangedSubview(filterView)
        }
    }
    
}

final class MainScreenFilterCell: UIView {
    
    var onTap: (() -> Void)?
    
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(model: MainScreenFiltersView.Model) {
        titleLabel.text = model.title
        titleLabel.textColor = model.isSelected ? .systemBackground : .white
        backgroundColor = model.isSelected ? .yellow : .darkGray
    }
    
    @objc private func didTap() {
        onTap?()
    }
    
    private func setupViews() {
        backgroundColor = .darkGray
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        
        addSubview(titleLabel)
        
        titleLabel.font = .text3
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        titleLabel.pin(
            to: self,
            insets: UIEdgeInsets(top: 8, left: 12, bottom: -8, right: -12)
        )
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
}
