//
//  MainScreenCompletedTasksCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 16.06.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public final class MainScreenCompletedTasksCell: UICollectionViewCell, TouchAnimatable {
    
    static let identifier = "MainScreenCompletedTasksCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let disclosureIndicatorView = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        let container = UIStackView(arrangedSubviews: [iconView, titleLabel, disclosureIndicatorView])
        container.axis = .horizontal
        container.spacing = 8
        container.alignment = .center
        
        contentView.addSubview(container)
        container.pin(to: contentView)
        
        iconView.image = UIImage.asset(named: "cup")
        iconView.tintColor = .yellow
        iconView.contentMode = .scaleAspectFit
        iconView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        
        titleLabel.text = "main_screen_completed_tasks_title".localized
        titleLabel.textColor = .white
        titleLabel.font = .text3
        
        disclosureIndicatorView.image = UIImage.asset(named: "arrow")
        disclosureIndicatorView.tintColor = .lightGray
        disclosureIndicatorView.contentMode = .scaleAspectFit
        disclosureIndicatorView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        disclosureIndicatorView.widthAnchor.constraint(equalTo: disclosureIndicatorView.heightAnchor).isActive = true
        
        enableTouchAnimation()
    }
}
