//
//  DetectiveProfileScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 20/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItAPI
import DetectItCore
import MessageUI

final class DetectiveProfileScreen: Screen {
    
    // MARK: - UI elements
    
    private let closeButton = SolidButton.closeButton()
    
    private let contentView = StackViewController()
    
    private let headerView = DetectiveProfileHeaderView()
        
    private let totalScoreView = DetectiveProfileStatsView()
    private let correctAnswersPercentView = DetectiveProfileStatsView()
    private let solvedTasksCountView = DetectiveProfileStatsView()
    
    private let notificationsView = TitleAndToggleView()
    private let leaderboardButton = SolidButton.primaryButton()
    private let rateAppButton = SolidButton.primaryButton()
    private let inviteFriendButton = SolidButton.primaryButton()
    private let reportProblemButton = SolidButton.primaryButton()
    private let restorePurchasesButton = SolidButton.primaryButton()
    private let logoutButton = SolidButton.primaryButton()
    private let deleteAccountButton = SolidButton.primaryButton()
    
    // MARK: - Services
    
    private let api = DetectItAPI()
    
    // MARK: - State
    
    private var detectiveProfile: DetectiveProfile? {
        didSet {
            updateStats()
        }
    }
    
    // MARK: - Overriden methods

    override func loadView() {
        super.loadView()
        
        isStatusBarBlurred = true
        
        view.backgroundColor = .systemBackground
        
        view.layoutMargins.left = .hInset
        view.layoutMargins.right = .hInset
        
        contentView.place(into: self)
        
        contentView.setTopSpacing(48)
        contentView.appendChild(headerView)
        contentView.appendSpacing(24)
        contentView.appendChild(totalScoreView)
        contentView.appendSpacing(12)
        contentView.appendChild(correctAnswersPercentView)
        contentView.appendSpacing(12)
        contentView.appendChild(solvedTasksCountView)
        contentView.appendSpacing(24)
        contentView.appendChild(notificationsView)
        contentView.appendSpacing(24)
        contentView.appendChild(leaderboardButton)
        contentView.appendSpacing(8)
        contentView.appendChild(rateAppButton)
        contentView.appendSpacing(8)
        contentView.appendChild(inviteFriendButton)
        contentView.appendSpacing(8)
        contentView.appendChild(reportProblemButton)
        contentView.appendSpacing(8)
        contentView.appendChild(restorePurchasesButton)
        contentView.appendSpacing(8)
        contentView.appendChild(logoutButton)
        contentView.appendSpacing(8)
        contentView.appendChild(deleteAccountButton)
        contentView.setBottomSpacing(20)
        
        setupViews()
    }
    
    override func refresh() {
        super.refresh()
        
        updateHeader()
        updateStats()
        updateNotificationsStatus()
        
        loadDetectiveProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(.detectiveProfile)
    }
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func didToggleNotifications(isOn: Bool) {
        PushNotificationsService(alertPresenter: self).toggleNotifications(isOn: isOn) { isOn in
            self.notificationsView.isOn = isOn
        }
    }
    
    @objc private func didTapLeaderboardButton() {
        let screen = LeaderboardScreen()
        screen.modalPresentationStyle = .fullScreen
        screen.modalTransitionStyle = .crossDissolve
        self.present(screen, animated: true, completion: nil)
        
        Analytics.logButtonTap(title: leaderboardButton.title, screen: .detectiveProfile)
    }
    
    @objc private func didTapRateAppButton() {
        UIApplication.shared.open(AppRateManager.appStoreLink, options: [:], completionHandler: nil)
        
        Analytics.logButtonTap(title: rateAppButton.title, screen: .detectiveProfile)
    }
    
    @objc private func didTapInviteFriendButton() {
        let sharingController = UIActivityViewController(activityItems: [AppRateManager.appStoreLink], applicationActivities: nil)
        sharingController.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .saveToCameraRoll]
        sharingController.popoverPresentationController?.sourceView = inviteFriendButton
        
        present(sharingController, animated: true, completion: nil)
        
        Analytics.logButtonTap(title: inviteFriendButton.title, screen: .detectiveProfile)
    }
    
    @objc private func didTapReportProblemButton() {
        showReportProblem()
        
        Analytics.logButtonTap(title: reportProblemButton.title, screen: .detectiveProfile)
    }
    
    @objc private func didTapRestorePurchasesButton() {
        showLoadingHUD(title: "purchases_restoring_hud_title".localized)
        
        FullVersionManager.restorePurchases { [unowned self] success in
            success ? self.showSuccessHUD() : self.showErrorHUD(title: "error_hud_title".localized)
            self.hideHUD(after: 1)
        }
        
        Analytics.logButtonTap(title: restorePurchasesButton.title, screen: .detectiveProfile)
    }
    
    @objc private func didTapLogoutButton() {
        User.shared.clearCredentials()
        
        navigateToAuth()
        
        Analytics.logButtonTap(title: logoutButton.title, screen: .detectiveProfile)
    }
    
    @objc private func didTapDeleteAccountButton() {
        showAlert(
            title: "detective_profile_delete_account_alert_title".localized,
            message: "detective_profile_delete_account_alert_message".localized,
            actions:
                Screen.AlertAction(title: "detective_profile_delete_account_delete_action_title".localized, style: .destructive) { [unowned self] in
                    self.api.request(.deleteAccount) { [weak self] result in
                        switch result {
                        case let .success(response) where (200...299) ~= response.statusCode:
                            User.shared.clearCredentials()
                            
                            self?.navigateToAuth()
                        case let .failure(error):
                            self?.showErrorHUD(title: error.localizedDescription)
                        default:
                            self?.showErrorHUD(title: "unknown_error_message".localized)
                        }
                    }
                    
                    Analytics.logButtonTap(title: self.deleteAccountButton.title, screen: .detectiveProfile)
                },
                Screen.AlertAction(title: "detective_profile_delete_account_cancel_button_title".localized) {}
        )
    }
    
    private func setupViews() {
        totalScoreView.titleLabel.text = "detective_profile_total_score_title".localized
        correctAnswersPercentView.titleLabel.text = "detective_profile_correct_answer_percent".localized
        solvedTasksCountView.titleLabel.text = "detective_profile_solved_tasks_count".localized
        
        notificationsView.configure(title: "detective_profile_notifications_title".localized) { [unowned self] isOn in
            self.didToggleNotifications(isOn: isOn)
        }
        
        leaderboardButton.setTitle("main_screen_leaderboard_action_title".localized, for: .normal)
        rateAppButton.setTitle("detective_profile_rate_app_action_title".localized, for: .normal)
        inviteFriendButton.setTitle("detective_profile_invite_friend_button_title".localized, for: .normal)
        reportProblemButton.setTitle("main_screen_report_problem_action_title".localized, for: .normal)
        restorePurchasesButton.setTitle("main_screen_restore_purchases_action_title".localized, for: .normal)
        logoutButton.setTitle("detective_profile_logout_action_title".localized, for: .normal)
        deleteAccountButton.setTitle("detective_profile_delete_account_action_title".localized, for: .normal)

        [leaderboardButton, rateAppButton, inviteFriendButton, reportProblemButton, restorePurchasesButton, logoutButton, deleteAccountButton].forEach {
            $0.fill = .color(.darkBackground)
            $0.setTitleColor(.lightGray, for: .normal)
            $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            $0.heightConstraint?.isActive = false
        }
        
        leaderboardButton.setTitleColor(.yellow, for: .normal)
        deleteAccountButton.setTitleColor(.red, for: .normal)
        
        leaderboardButton.addTarget(self, action: #selector(didTapLeaderboardButton), for: .touchUpInside)
        rateAppButton.addTarget(self, action: #selector(didTapRateAppButton), for: .touchUpInside)
        inviteFriendButton.addTarget(self, action: #selector(didTapInviteFriendButton), for: .touchUpInside)
        reportProblemButton.addTarget(self, action: #selector(didTapReportProblemButton), for: .touchUpInside)
        restorePurchasesButton.addTarget(self, action: #selector(didTapRestorePurchasesButton), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(didTapDeleteAccountButton), for: .touchUpInside)
        
        rateAppButton.isHidden = !UIApplication.shared.canOpenURL(AppRateManager.appStoreLink)
        reportProblemButton.isHidden = !MFMailComposeViewController.canSendMail()
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateHeader() {
        headerView.configure(
            model: DetectiveProfileHeaderView.Model(
                alias: User.shared.alias ?? "",
                rank: FullVersionManager.hasBought ? "professional_detective".localized : nil
            )
        )
    }
    
    private func updateStats() {
        correctAnswersPercentView.isHidden = detectiveProfile == nil
        solvedTasksCountView.isHidden = detectiveProfile == nil
        
        if let detectiveProfile = detectiveProfile {
            correctAnswersPercentView.statsLabel.text = "\(detectiveProfile.correctAnswersPercent.rounded(precision: 2))%"
            totalScoreView.statsLabel.text = "\(detectiveProfile.totalScore)"
            solvedTasksCountView.statsLabel.text = "\(detectiveProfile.solvedTasksCount)"
        } else {
            totalScoreView.statsLabel.text = "\(User.shared.totalScore)"
        }
    }
    
    private func updateNotificationsStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsView.isOn =
                    settings.authorizationStatus == .authorized &&
                    UIApplication.shared.isRegisteredForRemoteNotifications
            }
        }
    }
    
    private func loadDetectiveProfile() {
        api.obtain(
            DetectiveProfile.self,
            target: .detectiveProfile,
            cacheKey: .init("detective_profile")
        ) { [weak self] result in
            switch result {
            case let .success(detectiveProfile):
                self?.detectiveProfile = detectiveProfile
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func showReportProblem() {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let viewController = MFMailComposeViewController()
        viewController.setPreferredSendingEmailAddress("mesterra.co@gmail.com")
        viewController.setToRecipients(["mesterra.co@gmail.com"])
        viewController.setSubject("report_problem_subject".localized)
        viewController.mailComposeDelegate = self
        
        present(viewController, animated: true, completion: nil)
    }
    
    private func navigateToAuth() {
        let sceneDelegate = (
            view.window?.windowScene?.delegate
            ?? UIApplication.shared.connectedScenes.first?.delegate
        ) as? SceneDelegate
        
        sceneDelegate?.logout()
    }
    
}

extension DetectiveProfileScreen: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
