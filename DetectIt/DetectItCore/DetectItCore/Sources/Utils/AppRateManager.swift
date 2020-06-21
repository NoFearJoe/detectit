//
//  AppRateManager.swift
//  DetectItCore
//
//  Created by Илья Харабет on 21/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import StoreKit

public final class AppRateManager {
    
    public static let shared = AppRateManager()
    
    public static let appStoreLink = URL(string: "itms-apps://itunes.apple.com/app/id1507648958")!
    
    private init() {}
    
    private var isAppRateAlertShown: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isAppRateAlertShown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isAppRateAlertShown")
        }
    }
    
    private var countOfHappenedEventsToRateTheApp: Int {
        get {
            UserDefaults.standard.integer(forKey: "countOfHappenedEventsToRateTheApp")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "countOfHappenedEventsToRateTheApp")
        }
    }
    
    private let countOfEventsNeededToShowAppRateAlert = 3
    
    public func commitEvent() {
        guard !isAppRateAlertShown else { return }
        
        countOfHappenedEventsToRateTheApp += 1
        
        guard countOfHappenedEventsToRateTheApp >= countOfEventsNeededToShowAppRateAlert else {
            return
        }
        
        SKStoreReviewController.requestReview()
        
        isAppRateAlertShown = true
    }
    
}
