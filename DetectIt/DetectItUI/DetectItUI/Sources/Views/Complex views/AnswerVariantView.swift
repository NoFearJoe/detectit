//
//  AnswerVariantView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class AnswerVariantView: UIView {
    
    public var onTap: (() -> Void)?
    
    public let titleLabel = UILabel()
    
    public var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? .darkGray : .clear
            titleLabel.textColor = isSelected ? .yellow : .white
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 2
        
        addSubview(titleLabel)
        
        titleLabel.font = .text3
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.isUserInteractionEnabled = false
        
        titleLabel.pin(
            to: self,
            insets: UIEdgeInsets(top: 12, left: 4, bottom: -12, right: -4)
        )
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackground)))
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTapBackground() {
        onTap?()
    }
    
}
