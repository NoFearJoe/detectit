//
//  AppDelegate.swift
//  DetectIt
//
//  Created by Илья Харабет on 21/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import Amplitude
import DetectItCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FullVersionManager.completeTransactions()
        
        handleCommandLineArguments()
        
        #if !DEBUG
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().initializeApiKey("f82ec4c4d3370dc29ba7e17dc3152d8d")
        #endif
                
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

}

private extension AppDelegate {
    
    func handleCommandLineArguments() {
        #if DEBUG
        if CommandLineArguments.isOnboardingPassed {
            User.shared.isOnboardingShown = true
        }
        if let userAlias = CommandLineArguments.userAlias {
            User.shared.alias = userAlias
        }
        if let userPassword = CommandLineArguments.userPassword {
            User.shared.password = userPassword
        }
        #endif
    }
    
}
