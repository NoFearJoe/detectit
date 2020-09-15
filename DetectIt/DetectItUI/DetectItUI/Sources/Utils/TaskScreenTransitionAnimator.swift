//
//  TaskScreenTransitionAnimator.swift
//  DetectItUI
//
//  Created by Илья Харабет on 14.09.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class TaskScreenOpenTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let darkeningView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.tag = 666
        return view
    }()
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        1
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let container = transitionContext.containerView
        
        container.backgroundColor = .clear
        container.addSubview(darkeningView)
        darkeningView.frame = container.bounds
        
        UIView.animate(
            withDuration: 0.75,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.darkeningView.backgroundColor = .black
            },
            completion: { _ in
                container.insertSubview(toView, belowSubview: self.darkeningView)
                toView.frame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
                
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    options: .curveEaseOut,
                    animations: {
                        self.darkeningView.backgroundColor = .clear
                    },
                    completion: { _ in
                        self.darkeningView.removeFromSuperview()
                        transitionContext.completeTransition(true)
                    }
                )
            }
        )
    }
    
}

public final class TaskScreenCloseTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let darkeningView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.tag = 666
        return view
    }()
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let container = transitionContext.containerView
        
        container.backgroundColor = .clear
        container.addSubview(darkeningView)
        darkeningView.frame = container.bounds
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.darkeningView.backgroundColor = .black
            },
            completion: { _ in
                container.insertSubview(toView, belowSubview: self.darkeningView)
                toView.frame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
                
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    options: .curveEaseOut,
                    animations: {
                        self.darkeningView.backgroundColor = .clear
                    },
                    completion: { _ in
                        self.darkeningView.removeFromSuperview()
                        transitionContext.completeTransition(true)
                    }
                )
            }
        )
    }
    
}
