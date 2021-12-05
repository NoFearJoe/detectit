//
//  MainScreenPlaceholderCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 27.06.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public final class MainScreenPlaceholderCell: AutosizingCollectionViewCell {
    
    static let identifier = "MainScreenPlaceholderCell"
    
    private let messageLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(messageLabel)
        
        messageLabel.font = .text3
        messageLabel.textColor = .lightGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        messageLabel.pin(to: contentView)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public struct Model {
        public let message: String
        
        public init(message: String) {
            self.message = message
        }
    }
    
    public func configure(model: Model) {
        messageLabel.text = model.message
    }
    
}
