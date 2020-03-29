//
//  EvidenceCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 29/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

/// Ячейка, отображающая улику для "Выбора лишней улики".
public final class EvidenceCell: UICollectionViewCell {
    
    public static let identifier = String(describing: self)
    
    // MARK: - Subviews
    
    private let photoCardView = PhotoCardView()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public typealias Model = PhotoCardView.Model
    
    public func configure(model: Model) {
        photoCardView.photo = model.photo
        photoCardView.title = model.title
    }
    
    private func setupViews() {
        contentView.addSubview(photoCardView)
        
        photoCardView.configureShadow(
            radius: 4,
            opacity: 0.1,
            color: .black,
            offset: CGSize(width: 0, height: 2)
        )
        
        photoCardView.pin(to: contentView)
    }
    
}
