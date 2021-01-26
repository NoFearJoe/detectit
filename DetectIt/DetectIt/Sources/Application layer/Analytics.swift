//
//  Analytics.swift
//  DetectIt
//
//  Created by Илья Харабет on 26.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Amplitude

struct Analytics {
    
    static func log(_ event: String, parameters: [String: Any] = [:]) {
        #if !DEBUG
        Amplitude.instance().logEvent(event, withEventProperties: parameters)
        #endif
    }
    
    static func logScreenShow(_ screen: Screen) {
        #if !DEBUG
        log("screen_showed", parameters: ["name": screen.rawValue])
        #endif
    }
    
    static func logButtonTap(title: String, screen: Screen) {
        #if !DEBUG
        log("button_tapped", parameters: ["title": title, "screen": screen.rawValue])
        #endif
    }
    
}

extension Analytics {
    
    enum Screen: String {
        case onboarding
        case tasksOnboarding = "tasks_onboarding"
        case authPrepare = "auth_prepare"
        case auth
        case authProblems = "auth_problems"
        case restorePassword = "restore_password"
        case main
        case detectiveProfile = "detective_profile"
        case leaderboard
        case fullVersionPurchase = "full_version_purchase"
        case cipherTask = "cipher_task"
        case profileTask = "profile_task"
        case questTask = "quest_task"
        case tasksBundle = "tasks_bundle"
    }
    
}
