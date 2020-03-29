//
//  PaperSheetView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 29/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class PaperSheetView: UIView {
    
    // MARK: - Model
    
    public struct Model {
        public let title: String
        public let text: String
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title?.uppercased()
        }
    }
    
    var text: String? {
        didSet {
            textView.text = text
        }
    }
    
    // MARK: - Subviews
    
    private let titleLabel = UILabel()
    private let textView = UITextView()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public func configure(model: Model) {
        title = model.title
        text = model.text
    }
    
    // MARK: - Setup
    
    func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        layoutMargins = UIEdgeInsets(top: 32, left: 12, bottom: 32, right: 12)
        
        backgroundColor = .paper
        
        heightAnchor.constraint(equalTo: widthAnchor, multiplier: 30/21).isActive = true
    }
    
    func setupViews() {
        addSubview(titleLabel)
        addSubview(textView)
        
        titleLabel.font = .title(24)
        titleLabel.textColor = .mainText
        titleLabel.numberOfLines = 0
        
        textView.font = .text(14)
        textView.textColor = .mainText
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .paper
        textView.contentInset = .zero
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        ])
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            textView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Utils
    
}
