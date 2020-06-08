//
//  AuthNavigationScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 07/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class AuthNavigationScreen: UINavigationController {
    
    var onFinish: (() -> Void)?
    
    init() {
        let initialScreen: Screen = {
            if Self.isAuthPrepareScreenShown {
                return AuthScreen()
            } else {
                return AuthPrepareScreen()
            }
        }()
        
        Self.isAuthPrepareScreenShown = true
        
        super.init(rootViewController: initialScreen)
        
        if let authPrepareScreen = initialScreen as? AuthPrepareScreen {
            authPrepareScreen.onContinue = { [unowned self] in
                let authScreen = AuthScreen()
                authScreen.onFinish = { [unowned self] in
                    self.onFinish?()
                }
                self.pushViewController(authScreen, animated: true)
            }
        } else if let authScreen = initialScreen as? AuthScreen {
            authScreen.onFinish = { [unowned self] in
                self.onFinish?()
            }
        }
        
        isNavigationBarHidden = true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private static var isAuthPrepareScreenShown: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isAuthPrepareScreenShown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isAuthPrepareScreenShown")
        }
    }
    
}
