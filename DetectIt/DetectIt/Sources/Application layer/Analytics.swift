//
//  Analytics.swift
//  DetectIt
//
//  Created by Илья Харабет on 26.01.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Foundation
//import Amplitude

struct Analytics {
    
    static func log(_ event: String, parameters: [String: Any] = [:]) {
//        #if !DEBUG
//        Amplitude.instance().logEvent(event, withEventProperties: parameters)
//        #endif
    }
    
    static func logScreenShow(_ screen: Screen, parameters: [String: Any] = [:]) {
        #if !DEBUG
        log("screen_showed", parameters: parameters.merging(["name": screen.rawValue], uniquingKeysWith: { _, new in new }))
        #endif
    }
    
    static func logButtonTap(title: String, screen: Screen) {
        #if !DEBUG
        log("button_tapped", parameters: ["title": title, "screen": screen.rawValue])
        #endif
    }
    
    static func logScreenError(screen: Screen) {
        #if !DEBUG
        log("error_showed", parameters: ["screen": screen.rawValue])
        #endif
    }
    
    static func logRevenue(price: Double, productID: String) {
//        #if !DEBUG
//        let revenue = AMPRevenue()
//        revenue.setPrice(NSNumber(value: price))
//        revenue.setRevenueType("purchase")
//        revenue.setProductIdentifier(productID)
//        
//        Amplitude.instance().logRevenueV2(revenue)
//        #endif
    }
    
    static func setProperty(_ name: String, value: Any) {
//        #if !DEBUG
//        Amplitude.instance().setUserProperties([name: value])
//        #endif
    }
    
    // MARK: Special methods
    
    static func setStartAppVersionUserProperty() {
        guard !UserDefaults.standard.bool(forKey: "start_app_version_property_set") else { return }
        
        UserDefaults.standard.set(true, forKey: "start_app_version_property_set")
        
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        
        setProperty("start_app_version", value: version)
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
        case completedTasks = "completed_tasks"
        case cipherTask = "cipher_task"
        case profileTask = "profile_task"
        case blitzTask = "blitz_task"
        case questTask = "quest_task"
        case tasksBundle = "tasks_bundle"
        case tasksCompilation = "tasks_compilation"
        case dailyLimitExceeded = "daily_limit_exceeded"
        case ad
    }
    
}
