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
    
    private var screenView: MainScreenView? {
        view as? MainScreenView
    }
    
    private let screenLoadingView = ScreenLoadingView(isInitiallyHidden: false)
    
    private let api = DetectItAPI()
    
    // MARK: - State
    
    private var feed: Feed?
    private var taskBundlesPurchaseStates: [String: TasksBundlePurchaseState] = [:]
    
    private let actions = Action.allCases.filter {
        switch $0 {
        case .reportProblem:
            return MFMailComposeViewController.canSendMail()
        case .restorePurchases:
            return true
        case .debugMenu:
            #warning("Uncomment before release")
            return true
//            #if DEBUG
//            return true
//            #else
//            return false
//            #endif
        }
    }
    
    // MARK: - Overrides
    
    override func loadView() {
        view = MainScreenView(delegate: self)
        
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
    }
    
    override func prepare() {
        super.prepare()
        
        isStatusBarBlurred = true
        
        PaidTaskBundlesManager.obtainProductsInfo()
                
        PaidTaskBundlesManager.subscribeToProductsInfoLoading(self) {
            self.taskBundlesPurchaseStates = MainScreenDataLoader.getPurchaseStates(bundleIDs: PaidTaskBundlesManager.BundleID.allCases.map { $0.rawValue })
            self.screenView?.shallowReloadData()
        }
        
        loadFeed()
    }
    
    override func refresh() {
        super.refresh()
        
        screenView?.reloadHeader()
        
        taskBundlesPurchaseStates = MainScreenDataLoader.getPurchaseStates(bundleIDs: PaidTaskBundlesManager.BundleID.allCases.map { $0.rawValue })
        screenView?.shallowReloadData()
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
            rank: User.shared.rank.title
        )
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
                scoreColor: UIColor.score(value: item.score, max: item.maxScore)
            )
        case .bundle:
            return TasksBundleCell.Model(
                backgroundImagePath: item.picture,
                title: item.title,
                description: item.subtitle ?? ""
            )
        }
    }
    
    func tasksBundleShallowModel(at index: Int) -> TasksBundleCell.ShallowModel? {
        guard let bundle = feed?.items[index] else { return nil }
        guard let state = taskBundlesPurchaseStates[bundle.id] else { return nil }
        
        switch state {
        case .free, .bought:
            return TasksBundleCell.ShallowModel(playState: .playable)
        case .paidLoading:
            return TasksBundleCell.ShallowModel(playState: .loading)
        case let .paid(price):
            return TasksBundleCell.ShallowModel(playState: .paid(price: price))
        case .paidLocked:
            return nil // TODO: Handle
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
    
    func didTapBuyTasksBundleButton(at index: Int) {
        guard let bundle = feed?.items[index] else { return }
        
        showLoadingHUD(title: nil)
        
        PaidTaskBundlesManager.purchase(bundleID: bundle.id) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.showErrorHUD(title: error.localizedDescription)
                self.hideHUD(after: 2)
            } else {
                self.showSuccessHUD()
                self.hideHUD(after: 1)
            }
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
            
            PaidTaskBundlesManager.restorePurchases { [unowned self] success in
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
        screenLoadingView.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: false)
        
        api.request(.feed) { [weak self] result in
            guard let self = self else { return }
                                                
            switch result {
            case let .success(response):
                guard let feed = try? JSONDecoder().decode(Feed.self, from: response.data) else {
                    self.screenPlaceholderView.setVisible(true, animated: false)
                    self.screenLoadingView.setVisible(false, animated: true)
                    return self.screenPlaceholderView.configure(
                        title: "unknown_error_title".localized,
                        message: "unknown_error_message".localized,
                        onRetry: { [unowned self] in self.loadFeed() },
                        onClose: nil
                    )
                }
                
                self.screenLoadingView.setVisible(false, animated: true)
                
                self.feed = feed
                self.screenView?.reloadData()
            case .failure:
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
        viewController.setSubject("Проблема в Detect")
        viewController.mailComposeDelegate = self
        
        present(viewController, animated: true, completion: nil)
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
