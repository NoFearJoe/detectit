//
//  MainScreen+Banner.swift
//  DetectIt
//
//  Created by Илья Харабет on 06.02.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

extension MainScreen {
    
    enum Banner: String, CaseIterable {
        case appReviewRequest
        case subscribeToNotificationsRequest
    }
    
}

extension MainScreen.Banner {
    
    var priority: Int {
        switch self {
        case .appReviewRequest: return 1
        case .subscribeToNotificationsRequest: return 2
        }
    }
    
    var title: String {
        switch self {
        case .appReviewRequest:
            return "main_screen_banner_app_review_title".localized
        case .subscribeToNotificationsRequest:
            return "main_screen_banner_subscribe_to_notifications_title".localized
        }
    }
    
    var subtitle: String {
        switch self {
        case .appReviewRequest:
            return "main_screen_banner_app_review_subtitle".localized
        case .subscribeToNotificationsRequest:
            return "main_screen_banner_subscribe_to_notifications_subtitle".localized
        }
    }
    
}

extension MainScreen {
    
    func handleBannerTap(_ banner: Banner) {
        setBannerShown(banner)
        
        showingBanner = nil
        screenView.reloadBanner()
        
        switch banner {
        case .appReviewRequest:
            UIApplication.shared.open(AppRateManager.appStoreLink, options: [:], completionHandler: nil)
        case .subscribeToNotificationsRequest:
            PushNotificationsService(alertPresenter: self).toggleNotifications(isOn: true) { _ in }
        }
        
        Analytics.log(
            "banner_tapped",
            parameters: [
                "screen": Analytics.Screen.main.rawValue,
                "banner": banner.rawValue
            ]
        )
    }
    
    func handleBannerClose(_ banner: Banner) {
        setBannerShown(banner)
        
        showingBanner = nil
        screenView.reloadBanner()
        
        Analytics.log(
            "banner_closed",
            parameters: [
                "screen": Analytics.Screen.main.rawValue,
                "banner": banner.rawValue
            ]
        )
    }
    
    func showBannerIfPossible() {
        guard
            showingBanner == nil,
            let banner = Banner.allCases
                .sorted(by: { $0.priority < $1.priority })
                .first(where: { shouldShowBanner($0) })
        else { return }
        
        self.showingBanner = banner
        
        screenView.reloadBanner()
    }
    
    private func shouldShowBanner(_ banner: Banner) -> Bool {
        guard !isBannerShown(banner) else { return false }
        
        switch banner {
        case .appReviewRequest:
            return User.shared.totalScore >= 20
        case .subscribeToNotificationsRequest:
            return !UIApplication.shared.isRegisteredForRemoteNotifications
        }
    }
    
    func setBannerShown(_ banner: Banner) {
        UserDefaults.standard.set(true, forKey: "main_screen_banner_" + banner.rawValue)
    }
    
    private func isBannerShown(_ banner: Banner) -> Bool {
        UserDefaults.standard.bool(forKey: "main_screen_banner_" + banner.rawValue)
    }
    
}
