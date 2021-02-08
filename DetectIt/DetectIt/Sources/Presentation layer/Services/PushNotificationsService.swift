//
//  PushNotificationsService.swift
//  DetectIt
//
//  Created by Илья Харабет on 08.02.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import UserNotifications

struct PushNotificationsService {
    
    unowned let alertPresenter: Screen
    
    func toggleNotifications(isOn: Bool, completion: @escaping (Bool) -> Void) {
        if isOn {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .authorized:
                        UIApplication.shared.registerForRemoteNotifications()
                    case .denied:
                        self.alertPresenter.showAlert(
                            title: "detective_profile_enable_notifications_alert_title".localized,
                            message: "detective_profile_enable_notifications_alert_message".localized,
                            actions:
                                Screen.AlertAction(title: "detective_profile_enable_notifications_alert_settings_action_title".localized) {
                                    guard let url = try? UIApplication.openSettingsURLString.asURL() else { return }
                                    UIApplication.shared.open(url)
                                },
                            Screen.AlertAction(title: "detective_profile_enable_notifications_alert_cancel_action_title".localized) {
                                completion(false)
                            }
                        )
                    default:
                        UNUserNotificationCenter.current().requestAuthorization(
                            options: [.alert, .badge, .sound]
                        ) { granted, _ in
                            DispatchQueue.main.async {
                                if granted {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                                completion(granted)
                            }
                        }
                    }
                }
            }
        } else {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
}
