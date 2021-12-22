//
//  TagView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 23.02.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

public final class TagView: UIView {
    
    public var icon: UIImage? {
        didSet {
            iconView.image = icon
            iconView.isHidden = icon == nil
        }
    }
    
    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setupViews() {
        backgroundColor = .darkBackground
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        
        let container = UIStackView(arrangedSubviews: [titleLabel, iconView])
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 4
        
        addSubview(container)
        
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .red
        iconView.isHidden = true
        iconView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        
        titleLabel.font = .text4
        titleLabel.textColor = .lightGray
        titleLabel.textAlignment = .center
        
        container.pin(
            to: self,
            insets: UIEdgeInsets(top: 4, left: 6, bottom: -4, right: -6)
        )
    }
    
}
