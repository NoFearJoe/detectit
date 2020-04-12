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
        
        titleLabel.pin(to: contentView)
        
        contentView.addGestureRecognizer(TouchGestureRecognizer(action: { [unowned self] recognizer in
            switch recognizer.state {
            case .began, .changed:
                self.contentView.backgroundColor = .lightGray
            default:
                self.contentView.backgroundColor = .darkGray
            }
        }))
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
}
