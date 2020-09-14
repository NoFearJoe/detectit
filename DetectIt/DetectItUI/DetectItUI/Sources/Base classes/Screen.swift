//
//  Screen.swift
//  DetectItUI
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import JGProgressHUD

/// Базовый класс для любого экрана приложения.
open class Screen: UIViewController {
    
    // MARK: - Public methods
    
    public var statusBarFrame: CGRect {
        view.window?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
    }
    
    public let screenPlaceholderView = ScreenPlaceholderView()
    
    open func prepare() {}
    
    open func refresh() {}
    
    // MARK: - Overrides
    
    open override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    @available(*, unavailable)
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        
        view.addSubview(screenPlaceholderView)
        screenPlaceholderView.pin(to: view)
        screenPlaceholderView.setVisible(false, animated: false)
        
        prepare()
    }
    
    @available(*, unavailable)
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
        
        updateStatusBarBlurView()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateStatusBarBlurView()
    }
    
    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        updateStatusBarBlurView()
    }
    
    // MARK: - Status bar blur
    
    public var isStatusBarBlurred: Bool = false {
        didSet {
            setStatusBarBlurred(isStatusBarBlurred)
        }
    }
    
    private var statusBarBlurView: UIView?
    
    private func setStatusBarBlurred(_ isBlurred: Bool) {
        if isBlurred {
            guard statusBarBlurView == nil else { return }
            
            let blurView = BlurView(style: .dark)
            blurView.blurRadius = 28
            blurView.colorTint = UIColor.black.withAlphaComponent(0.5)
//            blurView.colorTintAlpha = 0.5
            
            view.addSubview(blurView)
            
            statusBarBlurView = blurView
        } else {
            statusBarBlurView?.removeFromSuperview()
            statusBarBlurView = nil
        }
    }
    
    private func updateStatusBarBlurView() {
        guard let statusBarBlurView = statusBarBlurView else { return }
        
        statusBarBlurView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.safeAreaInsets.top)
        view.bringSubviewToFront(statusBarBlurView)
    }
    
    // HUD
    
    private var hud: JGProgressHUD?
    
    public func showLoadingHUD(title: String?) {
        hud = JGProgressHUD(style: .dark)
        hud?.textLabel.text = title
        hud?.show(in: view)
    }
    
    public func showSuccessHUD() {
        if hud == nil {
            showLoadingHUD(title: nil)
        }
        
        hud?.textLabel.text = nil
        hud?.indicatorView = JGProgressHUDSuccessIndicatorView()
    }
    
    public func showErrorHUD(title: String) {
        if hud == nil {
            showLoadingHUD(title: nil)
        }
        
        hud?.textLabel.text = title
        hud?.indicatorView = JGProgressHUDErrorIndicatorView()
    }
    
    public func hideHUD(after delay: TimeInterval) {
        hud?.dismiss(afterDelay: delay)
        hud = nil
    }
    
}
