//
//  FloatingViewVisibilityManager.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

/// The class, that manages a UIView, which should be shown/hidden synchronously
/// with scroll of a UIScrollView.
public final class FloatingViewVisibilityManager {
    
    /// Defines behavior of the floatingView.
    public enum Mode {
        
        /// The floatingView will be shifted synchronously with content offset change.
        case followScroll
        
        /// The floatingView will be shifted on its height.
        /// Use this mode if you want to make the floatingView
        /// always able to be shown whenever you want.
        case hideOutOfScreen
        
    }
    
    // MARK: - Public variables
    
    public weak var floatingView: UIView?
    public weak var scrollView: UIScrollView? {
        didSet {
            subscribeToScrollViewContentOffset()
        }
    }
    
    /// A closure, called when floatingView changes its position.
    public var onChangeTranslation: ((_ isOnInitialPosition: Bool) -> Void)?
    
    // MARK: - Private variables
    
    private let mode: Mode
    
    private var isEnabled: Bool = false
    
    private var previousContentOffset: CGFloat = 0
    
    private var contentOffsetObservation: NSKeyValueObservation?
    
    // MARK: - Initializers
    
    public init(mode: Mode = .followScroll,
                floatingView: UIView,
                scrollView: UIScrollView) {
        self.mode = mode
        self.floatingView = floatingView
        self.scrollView = scrollView
        
        subscribeToScrollViewContentOffset()
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    /// You can call this method to show or hide the floatingView depends on its position.
    ///
    /// If the floatingView is hidden by half, it will be hidden,
    /// otherwise, returned to its initial position with animation.
    public func completeTranslation() {
        guard isEnabled, let floatingView = floatingView else { return }
        
        let shouldTranslateToInitialPosition
            = previousContentOffset <= floatingView.bounds.height
        
        let targetTransform: CGAffineTransform = {
            if shouldTranslateToInitialPosition {
                return CGAffineTransform(translationX: 0, y: -previousContentOffset)
            } else {
                let shouldShowFloatingView
                    = -floatingView.transform.ty <= floatingView.bounds.height * 0.5
                return shouldShowFloatingView
                    ? .identity
                    : CGAffineTransform(translationX: 0, y: -floatingView.bounds.height)
            }
        }()
        
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                floatingView.transform = targetTransform
        },
            completion: { _ in
                self.onChangeTranslation?(shouldTranslateToInitialPosition)
        }
        )
    }
    
}

// MARK: - Private extensions

private extension FloatingViewVisibilityManager {
    
    func updateTranslation(withContentOffset offset: CGFloat) {
        guard
            isEnabled,
            let scrollView = scrollView,
            let floatingView = floatingView
            else {
                return
        }
        
        let offsetWithInset = offset + scrollView.adjustedContentInset.top
        
        guard offsetWithInset >= 0, !floatingView.isHidden else {
            floatingView.transform = .identity
            onChangeTranslation?(true)
            previousContentOffset = 0
            
            return
        }
        
        let offsetDifference = previousContentOffset - offsetWithInset
        let translation = floatingView.transform.ty + offsetDifference
        
        let targetOffset: CGFloat = {
            switch mode {
            case .followScroll:
                return -translation
            case .hideOutOfScreen:
                return max(0, min(floatingView.bounds.height, -translation))
            }
        }()
        
        floatingView.transform = CGAffineTransform(translationX: 0, y: -targetOffset)
        
        previousContentOffset = offsetWithInset
        
        // limitedOffset is equal to offset when floatingView shifts relative to initial position.
        onChangeTranslation?(targetOffset == offsetWithInset)
    }
    
    func subscribeToScrollViewContentOffset() {
        contentOffsetObservation = scrollView?.observe(
            \.contentOffset,
            options: .new
        ) { [weak self] _, change in
            guard let offset = change.newValue?.y else { return }
            
            self?.updateTranslation(withContentOffset: offset)
        }
    }
    
}
