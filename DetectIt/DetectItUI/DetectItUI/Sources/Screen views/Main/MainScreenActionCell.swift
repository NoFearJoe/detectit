//
//  MainScreenActionCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 12/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class MainScreenActionCell: UICollectionViewCell {
    
    static let identifier = String(describing: MainScreenActionCell.self)
    
    private let titleLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 12
        contentView.backgroundColor = .darkGray
        
        contentView.addSubview(titleLabel)
        
        titleLabel.font = .text3
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        titleLabel.pin(to: contentView, insets: UIEdgeInsets(top: 12, left: 12, bottom: -12, right: -12))
        
        let recognizer = TouchGestureRecognizer(action: { [unowned self] recognizer in
            switch recognizer.state {
            case .began, .changed:
                self.contentView.backgroundColor = .lightGray
            default:
                self.contentView.backgroundColor = .darkGray
            }
        })
        
        recognizer.cancelsTouchesInView = false
        
        contentView.addGestureRecognizer(recognizer)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    func calculateSize(model: String, width: CGFloat) -> CGSize {
        configure(title: model)
        
        setNeedsLayout()
        layoutIfNeeded()
        
        return contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
    }
    
}
