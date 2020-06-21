//
//  MainScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 01/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore
import DetectItAPI
import MessageUI

final class MainScreen: Screen {
    
    var screenView: MainScreenView? {
        view as? MainScreenView
    }
    
    private let screenLoadingView = ScreenLoadingView(isInitiallyHidden: false)
    
    private let api = DetectItAPI()
    
    // MARK: - State
    
    private var feed: Feed?
    
    private let actions = Action.allCases.filter {
        switch $0 {
        case .reportProblem:
            return MFMailComposeViewController.canSendMail()
        case .restorePurchases:
            return true
        case .debugMenu:
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
    
    // MARK: - Overrides
    
    override func loadView() {
        view = MainScreenView(delegate: self)
        
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
        
        setupAccessibilityIDs()
    }
    
    override func prepare() {
        super.prepare()
        
        isStatusBarBlurred = true
        
        FullVersionManager.obtainProductInfo()
    }
    
    override func refresh() {
        super.refresh()
        
        screenView?.reloadHeader()
        
        loadFeed()
        loadTotalScore()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.screenView?.reloadData()
        })
    }
    
}

extension MainScreen: MainScreenViewDelegate {
    
    func header() -> MainScreenHeaderView.Model {
        .init(
            alias: User.shared.alias ?? "",
            rank: FullVersionManager.hasBought ? "professional_detective".localized : nil
        )
    }
    
    func didTapProfileButton() {
        let screen = DetectiveProfileScreen()
        screen.modalPresentationStyle = .fullScreen
        screen.modalTransitionStyle = .crossDissolve
        present(screen, animated: true, completion: nil)
    }
    
    func numberOfFeedItems() -> Int {
        feed?.items.count ?? 0
    }
    
    func feedItem(at index: Int) -> Any? {
        guard let item = feed?.items[index] else { return nil }
        
        switch item.kind {
        case .profile, .cipher:
            return MainScreenTaskCell.Model(
                backgroundImagePath: item.picture,
                kind: TaskKind(rawValue: item.kind.rawValue)?.title ?? "",
                title: item.title,
                description: item.subtitle ?? "",
                difficultyIcon: TaskDifficulty(rawValue: item.difficulty).icon,
                score: item.score.map { ScoreStringBuilder.makeScoreString(score: $0, max: item.maxScore) },
                scoreColor: UIColor.score(value: item.score, max: item.maxScore),
                isLocked: !FullVersionManager.hasBought && item.difficulty >= 3
            )
        case .bundle:
            return TasksBundleCell.Model(
                backgroundImagePath: item.picture,
                title: item.title,
                description: item.subtitle ?? ""
            )
        }
    }
    
    func didSelectFeedItem(at index: Int) {
        guard let item = feed?.items[index] else { return }
        
        switch item.kind {
        case .cipher:
            guard let cipher = item.cipher else { return }
            TaskScreenRoute(root: self).show(task: cipher, bundle: nil)
        case .profile:
            guard let profile = item.profile else { return }
            TaskScreenRoute(root: self).show(task: profile, bundle: nil)
        case .bundle:
            guard let tasksBundle = item.bundle else { return }
            showTasksBundle(bundle: tasksBundle, imageName: item.picture)
        }
    }
    
    func numberOfActions() -> Int {
        actions.count
    }
    
    func action(at index: Int) -> String? {
        actions[index].title
    }
    
    func didSelectAction(at index: Int) {
        switch actions[index] {
        case .reportProblem:
            showReportProblem()
        case .restorePurchases:
            showLoadingHUD(title: "purchases_restoring_hud_title".localized)
            
            FullVersionManager.restorePurchases { [unowned self] success in
                success ? self.showSuccessHUD() : self.showErrorHUD(title: "error_hud_title".localized)
                self.hideHUD(after: 1)
            }
        case .debugMenu:
            present(DebugMenuScreen(), animated: true, completion: nil)
        }
    }
    
}

private extension MainScreen {
    
    func loadFeed() {
        if feed == nil {
            screenLoadingView.setVisible(true, animated: false)
            screenPlaceholderView.setVisible(false, animated: false)
        }
        
        api.obtain(
            Feed.self,
            target: .feed,
            cacheKey: Cache.Key("feed")
        ) { [weak self] result in
            guard let self = self else { return }
                                                
            switch result {
            case let .success(feed):
                self.screenLoadingView.setVisible(false, animated: true)
                
                self.feed = feed
                self.screenView?.reloadData()
            case .failure:
                guard self.feed == nil else { return }
                
                self.screenPlaceholderView.setVisible(true, animated: false)
                self.screenLoadingView.setVisible(false, animated: true)
                self.screenPlaceholderView.configure(
                    title: "network_error_title".localized,
                    message: "network_error_message".localized,
                    onRetry: { [unowned self] in self.loadFeed() },
                    onClose: nil
                )
            }
        }
    }
    
    func loadTotalScore() {
        api.request(.totalScore) { [weak self] result in
            switch result {
            case let .success(response):
                guard let scoreString = try? response.mapString(), let score = Int(scoreString) else {
                    return
                }
                
                User.shared.totalScore = score
                
                self?.screenView?.reloadHeader()
            case .failure:
                return
            }
        }
    }
    
    func showTasksBundle(bundle: TasksBundle.Info, imageName: String?) {
        let tasksBundleScreen = TasksBundleScreen(
            tasksBundle: bundle,
            tasksBundleImageName: imageName ?? ""
        )
        
        tasksBundleScreen.modalTransitionStyle = .coverVertical
        tasksBundleScreen.modalPresentationStyle = .fullScreen
        
        present(tasksBundleScreen, animated: true, completion: nil)
    }
    
    func showReportProblem() {
        guard MFMailComposeViewController.canSendMail() else { return }
        
        let viewController = MFMailComposeViewController()
        viewController.setPreferredSendingEmailAddress("mesterra.co@gmail.com")
        viewController.setToRecipients(["mesterra.co@gmail.com"])
        viewController.setSubject("report_problem_subject".localized)
        viewController.mailComposeDelegate = self
        
        present(viewController, animated: true, completion: nil)
    }
    
}

extension MainScreen: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        screenView?.reloadData()
        screenView?.reloadHeader()
    }
    
}

extension MainScreen: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}


private extension MainScreen {
    
    enum Action: CaseIterable {
        case reportProblem
        case restorePurchases
        case debugMenu
        
        var title: String {
            switch self {
            case .reportProblem:
                return "main_screen_report_problem_action_title".localized
            case .restorePurchases:
                return "main_screen_restore_purchases_action_title".localized
            case .debugMenu:
                return "main_screen_debug_menu_action_title".localized
            }
        }
    }
    
}
