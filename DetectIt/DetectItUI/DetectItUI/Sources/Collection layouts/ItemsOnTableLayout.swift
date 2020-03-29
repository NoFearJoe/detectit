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
    
    public override func prepare() {
        super.prepare()
        
        guard let itemsCount = collectionView?.numberOfItems(inSection: 0) else { return }
        
        additionalAttributes = (0..<itemsCount).map {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: $0, section: 0))
            
            let angle = CGFloat.random(in: -1...1)
            let rotation = CGAffineTransform(rotationAngle: angle.radians)
            
            let translationX = CGFloat.random(in: -2...2)
            let translationY = CGFloat.random(in: -2...2)
            let translation = CGAffineTransform(translationX: translationX, y: translationY)
            
            attributes.transform = rotation.concatenating(translation)
            
            return attributes
        }
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        
        let additionalAttributes = self.additionalAttributes[indexPath.item]
        
        attributes.transform = additionalAttributes.transform
        
        return attributes
    }
    
}
