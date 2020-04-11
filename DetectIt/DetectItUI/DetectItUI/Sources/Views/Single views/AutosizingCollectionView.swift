//
//  AutosizingCollectionView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

open class AutosizingCollectionView: UICollectionView {
    
    open override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var contentInset: UIEdgeInsets {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        CGSize(
            width: contentInset.left + contentSize.width + contentInset.right,
            height: contentInset.top + contentSize.height + contentInset.bottom
        )
    }
    
    public override var bounds: CGRect {
        didSet {
            guard bounds != .zero else { return }
            guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
            
            let width = bounds.width - contentInset.left - contentInset.right
            layout.estimatedItemSize = CGSize(
                width: max(width, 0),
                height: 0
            )
        }
    }
    
}
