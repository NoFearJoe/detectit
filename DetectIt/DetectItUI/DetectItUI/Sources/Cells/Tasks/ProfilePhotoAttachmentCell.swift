//
//  ProfileAttachmentCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class ProfilePhotoAttachmentCell: AutosizingCollectionViewCell {
    
    public static let identifier = String(describing: ProfilePhotoAttachmentCell.self)
    
    // MARK: - Subviews
    
    private let paperSheetView = PaperSheetWithPhotoView()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Configuration
    
    public typealias Model = PaperSheetWithPhotoView.Model
    
    public func configure(model: Model) {
        paperSheetView.configure(model: model)
    }
    
    // MARK: - Setup
    
    func setupViews() {
        contentView.addSubview(paperSheetView)
        
        paperSheetView.configureShadow(
            radius: 4,
            opacity: 0.1,
            color: .black,
            offset: CGSize(width: 0, height: 2)
        )
        
        paperSheetView.pin(to: contentView)
    }
    
}
