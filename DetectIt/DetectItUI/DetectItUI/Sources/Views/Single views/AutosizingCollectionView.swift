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
    
}
