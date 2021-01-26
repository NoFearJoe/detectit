//
//  SceneDelegate.swift
//  DetectIt
//
//  Created by Илья Харабет on 21/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import Amplitude
import DetectItCore
import DetectItAPI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let api = DetectItAPI()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: scene)
        self.window = window

        if User.shared.isAuthorized {
            window.rootViewController = SplashScreen()
            api.chechAuthentication { isAuthorized, user in
                if isAuthorized {
                    user?.id.map { Amplitude.instance().setUserId("\($0)") }
                    
                    self.performTransition(to: MainScreen())
                } else {
                    self.showAuth()
                }
            }
        } else if User.shared.isOnboardingShown {
            showAuth()
        } else {
            showOnboarding()
        }
        
        window.makeKeyAndVisible()
    }
    
    private func performTransition(to screen: UIViewController) {
        guard let window = window else { return }
        
        let isRootScreen = window.rootViewController == nil
        
        window.subviews.forEach { $0.removeFromSuperview() }
        
        window.rootViewController = screen
        window.makeKeyAndVisible()
        
        guard !isRootScreen else { return }
        
        UIView.transition(
            with: window,
            duration: 1,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }
    
    private func showAuth() {
        let screen = AuthNavigationScreen()
        
        screen.onFinish = { [unowned self] in
            self.performTransition(to: MainScreen())
        }
        
        performTransition(to: screen)
    }
    
    private func showOnboarding() {
        let screen = OnboardingScreen()
        
        screen.onFinish = { [unowned self] in
            User.shared.isOnboardingShown = true
            
            self.showAuth()
        }
        
        performTransition(to: screen)
    }

}

