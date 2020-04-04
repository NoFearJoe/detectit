//
//  TouchGestureRecognizer.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

class TouchGestureRecognizer: UIGestureRecognizer {
    
    private var action: ((UIGestureRecognizer) -> Void)?
    
    init(action: ((UIGestureRecognizer) -> Void)?) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(onTouch))
    }
    
    @objc private func onTouch() {
        self.action?(self)
    }
    
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, let view = touch.view, !(view is UIControl) else { return }
        self.state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        guard let view = self.view, let point = touches.first?.location(in: view) else {
            return
        }
        
        if view.bounds.contains(point) {
            self.state = .possible
        } else {
            self.state = .ended
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.state = .cancelled
    }
}
