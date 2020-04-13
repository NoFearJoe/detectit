//
//  StackViewController.swift
//  DesignKit
//
//  Created by i.kharabet on 16/07/2019.
//  Copyright © 2019 ProjectX. All rights reserved.
//

import UIKit

open class StackViewController: UIViewController {
    
    // MARK: - Public variables
    
    /// The root view of the controller.
    public let scrollView = UIScrollView(frame: .zero)
    
    /// Child view controller instances added to the StackViewController.
    public private(set) var viewControllers: [UIViewController] = []
    
    /// The stack view.
    public let stackView = UIStackView(frame: .zero)
    
    // MARK: - Lifecycle functions
    
    open override func loadView() {
        view = scrollView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupScrollView()
        setupStackView()
        setupStackViewConstraints()
    }
    
    open func place(into viewController: UIViewController,
                    layout: ((UIView) -> Void)? = nil) {
        viewController.addChild(self)
        viewController.view.addSubview(self.view)
        
        if let layout = layout {
            layout(view)
        } else {
            view.pin(to: viewController.view)
        }
        
        stackView.layoutMargins = viewController.view.layoutMargins

        self.didMove(toParent: viewController)
    }
    
    public final func appendChild(_ child: StackViewControllerChild) {
        insertChild(child, at: viewControllers.count)
    }
    
    public final func setTopSpacing(_ spasing: CGFloat) {
        stackView.layoutMargins.top = spasing
    }
    
    public final func setBottomSpacing(_ spasing: CGFloat) {
        stackView.layoutMargins.bottom = spasing
    }
    
    public final func appendSpacing(_ spasing: CGFloat) {
        guard let lastSubview = stackView.arrangedSubviews.last else {
            return
        }
        
        stackView.setCustomSpacing(spasing, after: lastSubview)
    }
    
    public final func insertChild(_ child: StackViewControllerChild, at index: Int) {
        let childController = child.asViewController
        
        addChild(childController)
        
        let insertIndex = index
        
        viewControllers.insert(childController, at: insertIndex)
    
        stackView.insertArrangedSubview(childController.view, at: insertIndex)
        addHeightConstraint(toChild: childController)
        childController.didMove(toParent: self)
    }
    
    public final func removeChild(_ child: StackViewControllerChild, animated: Bool) {
        guard let index = viewControllers.firstIndex(where: { $0 === child.asViewController }) else { return }
        
        let childViewController = child.asViewController
        childViewController.willMove(toParent: nil)
        
        let removeFromHierarchy = {
            self.stackView.removeArrangedSubview(childViewController.view)
            childViewController.view.removeFromSuperview()
            childViewController.removeFromParent()
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    childViewController.view.isHidden = true
                },
                completion: { _ in
                    removeFromHierarchy()
                }
            )
        } else {
            removeFromHierarchy()
        }
        
        viewControllers.remove(at: index)
    }
    
    public final func setChildHidden(
        _ child: StackViewControllerChild,
        hidden: Bool,
        animated: Bool,
        animationDuration: TimeInterval = 0.3
    ) {
        let childViewController = child.asViewController
        
        let hideChild = {
            childViewController.view.alpha = hidden ? 0 : 1
        }
        
        childViewController.view.alpha = hidden ? 1 : 0
        childViewController.view.isHidden = hidden
        
        UIView.animate(withDuration: animated ? animationDuration : 0, animations: hideChild)
    }
    
}

// MARK: - Public extensions

public extension StackViewController {
    
    var contentHeight: CGFloat {
        stackView.systemLayoutSizeFitting(
            CGSize(width: UIScreen.main.bounds.width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        .height + scrollView.contentInset.top + scrollView.contentInset.bottom
    }

}

// MARK: - Private extensions

// MARK: Main view setup

private extension StackViewController {
    
    func setupView() {
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
}

// MARK: Scroll view setup

private extension StackViewController {
    
    func setupScrollView() {
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.bouncesZoom = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 1
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.delaysContentTouches = false
        scrollView.keyboardDismissMode = .onDrag
    }
    
}

// MARK: Stack view setup

private extension StackViewController {
    
    func setupStackView() {
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        scrollView.addSubview(stackView)
    }
    
    func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ])
    }
    
}

// MARK: Child views managing

private extension StackViewController {
    
    func addHeightConstraint(toChild childController: UIViewController) {
        childController.view.translatesAutoresizingMaskIntoConstraints = false
        if let staticHeightController = childController as? StaticHeightStackChildController {
            childController.view.heightAnchor.constraint(equalToConstant: staticHeightController.height).isActive = true
        } else if let dynamicHeightController = childController as? DynamicHeightStackChildController {
            let constraint = childController.view.heightAnchor.constraint(equalToConstant: 0)
            constraint.isActive = true
            dynamicHeightController.onChangeHeight = { newHeight in
                constraint.constant = newHeight
            }
        }
    }
    
}
