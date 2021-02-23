//
//  TagView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 23.02.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

public final class TagView: UIView {
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupViews() {
        backgroundColor = .darkBackground
        layer.cornerRadius = 8
        
        addSubview(titleLabel)
        
        titleLabel.font = .text4
        titleLabel.textColor = .lightGray
        titleLabel.textAlignment = .center
        
        titleLabel.pin(
            to: self,
            insets: UIEdgeInsets(top: 4, left: 6, bottom: -4, right: -6)
        )
    }
    
}
