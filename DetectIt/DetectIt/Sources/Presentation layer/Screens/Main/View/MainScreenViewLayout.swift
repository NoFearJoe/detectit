//
//  MainScreenViewLayout.swift
//  DetectIt
//
//  Created by Илья Харабет on 22.12.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

final class MainScreenViewLayout: UICollectionViewFlowLayout {

    lazy var dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    private var visibleIndexPaths = Set<IndexPath>()
    private var latestDelta = CGFloat(0)
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        // expand the visible rect slightly to avoid flickering when scrolling quickly
        let expandBy: CGFloat = -100
        let visibleRect = CGRect(origin: collectionView.bounds.origin,
                                 size: collectionView.frame.size).insetBy(dx: expandBy, dy: 0)
        
        guard let visibleItems = super.layoutAttributesForElements(in: visibleRect) else { return }
        let indexPathsInVisibleRect = Set(visibleItems.map{ $0.indexPath })
        
        removeNoLongerVisibleBehaviors(indexPathsInVisibleRect: indexPathsInVisibleRect)
        
        let newlyVisibleItems = visibleItems.filter { item in
            return !visibleIndexPaths.contains(item.indexPath)
        }
        
        addBehaviors(for: newlyVisibleItems)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator.layoutAttributesForCell(at: indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let scrollView = self.collectionView!
        let delta = newBounds.origin.y - scrollView.bounds.origin.y
        latestDelta = delta
        
        let touchLocation = collectionView!.panGestureRecognizer.location(in: collectionView)
        
        dynamicAnimator.behaviors.compactMap { $0 as? UIAttachmentBehavior }.forEach { behavior in
            let attrs = behavior.items.first as! UICollectionViewLayoutAttributes
            attrs.center = getUpdatedBehaviorItemCenter(behavior: behavior, touchLocation: touchLocation)
            self.dynamicAnimator.updateItem(usingCurrentState: attrs)
        }
        return false
    }
    
    private func removeNoLongerVisibleBehaviors(indexPathsInVisibleRect indexPaths: Set<IndexPath>) {
        //get no longer visible behaviors
        let noLongerVisibleBehaviours = dynamicAnimator.behaviors.filter { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior,
                let item = behavior.items.first as? UICollectionViewLayoutAttributes else { return false }
            return !indexPaths.contains(item.indexPath)
        }
        
        //remove no longer visible behaviors
        noLongerVisibleBehaviours.forEach { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior,
                let item = behavior.items.first as? UICollectionViewLayoutAttributes else { return }
            self.dynamicAnimator.removeBehavior(behavior)
            self.visibleIndexPaths.remove(item.indexPath)
        }
    }
    
    private func addBehaviors(for items: [UICollectionViewLayoutAttributes]) {
        guard let collectionView = collectionView else { return }
        let touchLocation = collectionView.panGestureRecognizer.location(in: collectionView)
        
        items.forEach { item in
            let springBehaviour = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
            
            springBehaviour.length = 0
            springBehaviour.damping = 1
            springBehaviour.frequency = 1
            
            if !CGPoint.zero.equalTo(touchLocation) {
                item.center = getUpdatedBehaviorItemCenter(behavior: springBehaviour, touchLocation: touchLocation)
            }
            
            self.dynamicAnimator.addBehavior(springBehaviour)
            self.visibleIndexPaths.insert(item.indexPath)
        }
    }
    
    private func getUpdatedBehaviorItemCenter(behavior: UIAttachmentBehavior,
                                              touchLocation: CGPoint) -> CGPoint {
        let yDistanceFromTouch = abs(touchLocation.y - behavior.anchorPoint.y)
        let xDistanceFromTouch = abs(touchLocation.x - behavior.anchorPoint.x)
        let scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / (15 * 100)
        
        let attrs = behavior.items.first as! UICollectionViewLayoutAttributes
        var center = attrs.center
        if latestDelta < 0 {
            center.y += max(latestDelta, latestDelta * scrollResistance)
        } else {
            center.y += min(latestDelta, latestDelta * scrollResistance)
        }
        return center
    }

}
