//
//  SceneDelegate.swift
//  DetectIt
//
//  Created by Илья Харабет on 21/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private var isOnboardingCompleted: Bool {
        User.shared.alias != nil
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: scene)
        
        if isOnboardingCompleted {
            window.rootViewController = MainScreen()
        } else {
            let screen = OnboardingScreen()
            
            screen.onFinish = { [unowned self] in
                self.performTransitionToMainScreen()
            }
            
            window.rootViewController = screen
        }
        
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
    private func performTransitionToMainScreen() {
        guard let window = window else { return }
        
        window.subviews.forEach { $0.removeFromSuperview() }
        
        window.rootViewController = MainScreen()
        window.makeKeyAndVisible()
        
        UIView.transition(
            with: window,
            duration: 1,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }

}

