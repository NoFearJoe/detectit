//
//  ProfilePrepositionCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 31/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfilePrepositionCell: AutosizingCollectionViewCell {
    
    public static let identifier = String(describing: ProfilePrepositionCell.self)
    
    // MARK: - Subviews
    
    private let pageSheetView = PaperSheetView()
        
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public typealias Model = PaperSheetView.Model
    
    public func configure(model: Model) {
        pageSheetView.configure(model: model)
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(pageSheetView)
        
        pageSheetView.configureShadow(
            radius: 4,
            opacity: 0.1,
            color: .black,
            offset: CGSize(width: 0, height: 2)
        )
        
        pageSheetView.pin(to: contentView)
    }
    
}
