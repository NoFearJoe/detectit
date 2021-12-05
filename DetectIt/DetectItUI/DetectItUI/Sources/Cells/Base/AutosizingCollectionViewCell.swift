//
//  AutosizingCollectionViewCell.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

open class AutosizingCollectionViewCell: UICollectionViewCell {
    
    public var axis: UICollectionView.ScrollDirection {
        .vertical
    }
    
    public override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        let targetSize = CGSize(
            width: axis == .vertical ? layoutAttributes.bounds.width : 0,
            height: axis == .vertical ? 0 : layoutAttributes.bounds.height
        )
        
        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: axis == .vertical ? .required : .defaultLow,
            verticalFittingPriority: axis == .vertical ? .defaultLow : .required
        )
        
        attributes.frame = CGRect(origin: attributes.frame.origin, size: size)
        
        return attributes
    }
    
}
