//
//  BlitzTaskScreen+KeyboardHandler.swift
//  DetectIt
//
//  Created by Илья Харабет on 21.11.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

extension BlitzTaskScreen {
    
    func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                if let offset = self.calculateTargetScrollViewYOffset(keyboardFrame: frame) {
                    self.contentScrollViewOffset = offset
                    self.contentContainer.scrollView.contentOffset.y += offset
                } else {
                    self.contentScrollViewOffset = nil
                }
                self.contentContainer.scrollView.contentInset.bottom = frame.height
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                if let contentScrollViewOffset = self.contentScrollViewOffset {
                    self.contentContainer.scrollView.contentOffset.y -= contentScrollViewOffset
                    self.contentScrollViewOffset = nil
                }
                self.contentContainer.scrollView.contentInset.bottom = 0
            }
        }
    }
    
    // MARK: - Utils
    
    func calculateTargetScrollViewYOffset(keyboardFrame: CGRect) -> CGFloat? {
        guard var focusedView = contentContainer.stackView.currentFirstResponder() as? UIView else { return nil }
        
        focusedView = focusedView.superview ?? focusedView
        
        let convertedFocusedViewFrame = focusedView.convert(focusedView.bounds, to: view)
        
        let visibleContentHeight = view.bounds.height - keyboardFrame.height
        
        let focusedViewMaxY = convertedFocusedViewFrame.maxY
        
        if visibleContentHeight > focusedViewMaxY {
            return nil
        } else {
            return max(0, focusedViewMaxY - visibleContentHeight)
        }
    }
    
}
