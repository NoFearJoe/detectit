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
import MessageUI

final class MainScreen: Screen {
    
    private var screenView: MainScreenView? {
        view as? MainScreenView
    }
    
    private let placeholderView = ScreenPlaceholderView(isInitiallyHidden: false)
    
    // MARK: - State
    
    private var taskBundles: [TasksBundle.Info] = []
    private var taskBundleImages: [String: UIImage] = [:]
    private var taskBundlesPurchaseStates: [String: TasksBundlePurchaseState] = [:]
    
    private let actions = Action.allCases.filter {
        guard $0 == .reportProblem else { return true }
        
        return MFMailComposeViewController.canSendMail()
    }
    
    // MARK: - Overrides
    
    override func loadView() {
        view = MainScreenView(delegate: self)
        
        view.addSubview(placeholderView)
        placeholderView.pin(to: view)
    }
    
    override func prepare() {
        super.prepare()
        
        isStatusBarBlurred = true
        
        PaidTaskBundlesManager.obtainProductsInfo()
        
        placeholderView.setVisible(true, animated: false)
        
        MainScreenDataLoader.loadData { data in
            self.placeholderView.setVisible(false, animated: true)
            
            guard let data = data else {
                // TODO: Error
                return
            }
            
            self.taskBundles = data.taskBundles
            self.taskBundleImages = data.taskBundleImages
            self.taskBundlesPurchaseStates = MainScreenDataLoader.getPurchaseStates(bundleIDs: data.taskBundles.map { $0.id })
            
            self.screenView?.reloadData()
            self.screenView?.shallowReloadData()
        }
        
        PaidTaskBundlesManager.subscribeToProductsInfoLoading(self) {
            self.taskBundlesPurchaseStates = MainScreenDataLoader.getPurchaseStates(bundleIDs: self.taskBundles.map { $0.id })
            self.screenView?.shallowReloadData()
        }
    }
    
    override func refresh() {
        super.refresh()
        
        screenView?.reloadHeader()
        
        taskBundlesPurchaseStates = MainScreenDataLoader.getPurchaseStates(bundleIDs: self.taskBundles.map { $0.id })
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
    
    func numberOfTaskBundles() -> Int {
        taskBundles.count
    }
    
    func tasksBundle(at index: Int) -> TasksBundleCell.Model? {
        let bundle = taskBundles[index]
        
        return TasksBundleCell.Model(
            backgroundImage: taskBundleImages[bundle.id] ?? UIImage(),
            title: bundle.title,
            description: bundle.description
        )
    }
    
    func tasksBundleShallowModel(at index: Int) -> TasksBundleCell.ShallowModel? {
        let bundle = taskBundles[index]
        
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
    
    func didSelectTasksBundle(at index: Int) {
        showTasksBundle(bundle: taskBundles[index])
    }
    
    func didTapBuyTasksBundleButton(at index: Int) {
        let bundle = taskBundles[index]
        
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
    
    // TODO
    func didSelectAction(at index: Int) {
        switch actions[index] {
        case .reportProblem:
            showReportProblem()
        case .restorePurchases:
            showLoadingHUD(title: "Восстановление покупок...")
            
            PaidTaskBundlesManager.restorePurchases { [unowned self] success in
                success ? self.showSuccessHUD() : self.showErrorHUD(title: "Что-то пошло не так")
                self.hideHUD(after: 1)
            }
        case .debugMenu:
            present(DebugMenuScreen(), animated: true, completion: nil)
        }
    }
    
}

private extension MainScreen {
    
    func showTasksBundle(bundle: TasksBundle.Info) {
        let tasksBundleScreen = TasksBundleScreen(
            tasksBundle: bundle,
            image: taskBundleImages[bundle.id] ?? UIImage()
        )
        
        tasksBundleScreen.modalTransitionStyle = .coverVertical
        tasksBundleScreen.modalPresentationStyle = .fullScreen
        
        present(tasksBundleScreen, animated: true, completion: nil)
    }
    
    func showTasksBundlePurchse(bundle: TasksBundle.Info, price: String) {
        // TODO
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
        
        // TODO
        var title: String {
            switch self {
            case .reportProblem:
                return "Сообщить о проблеме"
            case .restorePurchases:
                return "Восстановить покупки"
            case .debugMenu:
                return "Дебаг меню"
            }
        }
    }
    
}
