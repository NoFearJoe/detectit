//
//  ItemsOnTableLayout.swift
//  DetectItUI
//
//  Created by Илья Харабет on 29/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

/// Располагает ячейки с небольшим поворотом и сдвигом, создавая эффект разбросанных предметов на столе.
public final class ItemsOnTableLayout: UICollectionViewFlowLayout {
    
    private var additionalAttributes: [UICollectionViewLayoutAttributes] = []
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        newBounds.width != collectionView?.bounds.width
    }
    
    public override func shouldInvalidateLayout(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> Bool {
        false
    }
    
    public override func prepare() {
        super.prepare()
        
        guard let itemsCount = collectionView?.numberOfItems(inSection: 0) else { return }
        
        additionalAttributes = (0..<itemsCount).map {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: $0, section: 0))
            
            attributes.transform = CGAffineTransform.randomLayout()
            
            return attributes
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        attributes.forEach {
            let additionalAttributes = self.additionalAttributes[$0.indexPath.item]
            
            $0.transform = additionalAttributes.transform
        }
        
        return attributes
    }
    
}
