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
    
    private let leaderboardButton = SolidButton.primaryButton()
    private let rateAppButton = SolidButton.primaryButton()
    private let inviteFriendButton = SolidButton.primaryButton()
    private let reportProblemButton = SolidButton.primaryButton()
    private let restorePurchasesButton = SolidButton.primaryButton()
    
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
        contentView.appendChild(leaderboardButton)
        contentView.appendSpacing(8)
        contentView.appendChild(rateAppButton)
        contentView.appendSpacing(8)
        contentView.appendChild(inviteFriendButton)
        contentView.appendSpacing(8)
        contentView.appendChild(reportProblemButton)
        contentView.appendSpacing(8)
        contentView.appendChild(restorePurchasesButton)
        contentView.setBottomSpacing(20)
        
        setupViews()
    }
    
    override func refresh() {
        super.refresh()
        
        updateHeader()
        updateStats()
        
        loadDetectiveProfile()
    }
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapLeaderboardButton() {
        let screen = LeaderboardScreen()
        screen.modalPresentationStyle = .fullScreen
        screen.modalTransitionStyle = .crossDissolve
        self.present(screen, animated: true, completion: nil)
    }
    
    @objc private func didTapRateAppButton() {
        UIApplication.shared.open(AppRateManager.appStoreLink, options: [:], completionHandler: nil)
    }
    
    @objc private func didTapInviteFriendButton() {
        let sharingController = UIActivityViewController(activityItems: [AppRateManager.appStoreLink], applicationActivities: nil)
        sharingController.excludedActivityTypes = [.addToReadingList, .assignToContact, .markupAsPDF, .saveToCameraRoll]
        sharingController.popoverPresentationController?.sourceView = inviteFriendButton
        
        present(sharingController, animated: true, completion: nil)
    }
    
    @objc private func didTapReportProblemButton() {
        showReportProblem()
    }
    
    @objc private func didTapRestorePurchasesButton() {
        showLoadingHUD(title: "purchases_restoring_hud_title".localized)
        
        FullVersionManager.restorePurchases { [unowned self] success in
            success ? self.showSuccessHUD() : self.showErrorHUD(title: "error_hud_title".localized)
            self.hideHUD(after: 1)
        }
    }
    
    private func setupViews() {
        totalScoreView.titleLabel.text = "detective_profile_total_score_title".localized
        correctAnswersPercentView.titleLabel.text = "detective_profile_correct_answer_percent".localized
        solvedTasksCountView.titleLabel.text = "detective_profile_solved_tasks_count".localized
        
        leaderboardButton.setTitle("main_screen_leaderboard_action_title".localized, for: .normal)
        rateAppButton.setTitle("detective_profile_rate_app_action_title".localized, for: .normal)
        inviteFriendButton.setTitle("detective_profile_invite_friend_button_title".localized, for: .normal)
        reportProblemButton.setTitle("main_screen_report_problem_action_title".localized, for: .normal)
        restorePurchasesButton.setTitle("main_screen_restore_purchases_action_title".localized, for: .normal)

        [leaderboardButton, rateAppButton, inviteFriendButton, reportProblemButton, restorePurchasesButton].forEach {
            $0.fill = .color(.darkBackground)
            $0.setTitleColor(.lightGray, for: .normal)
            $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            $0.heightConstraint?.isActive = false
        }
        
        leaderboardButton.setTitleColor(.yellow, for: .normal)
        
        leaderboardButton.addTarget(self, action: #selector(didTapLeaderboardButton), for: .touchUpInside)
        rateAppButton.addTarget(self, action: #selector(didTapRateAppButton), for: .touchUpInside)
        inviteFriendButton.addTarget(self, action: #selector(didTapInviteFriendButton), for: .touchUpInside)
        reportProblemButton.addTarget(self, action: #selector(didTapReportProblemButton), for: .touchUpInside)
        restorePurchasesButton.addTarget(self, action: #selector(didTapRestorePurchasesButton), for: .touchUpInside)
        
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
    
}

extension DetectiveProfileScreen: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
