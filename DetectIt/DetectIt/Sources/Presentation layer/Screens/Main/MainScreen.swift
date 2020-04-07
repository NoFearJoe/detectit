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

final class MainScreen: Screen {
    
    private var screenView: MainScreenView {
        view as! MainScreenView
    }
    
    private let placeholderView = ScreenPlaceholderView(isInitiallyHidden: false)
    
    // MARK: - State
    
    private var taskBundles: [TasksBundle.Info] = []
    private var taskBundleImages: [String: UIImage] = [:]
    private var taskBundlesPurchaseStates: [String: TasksBundlePurchaseState] = [:]
    
    // MARK: - Overrides
    
    override func loadView() {
        view = MainScreenView(delegate: self)
        
        view.addSubview(placeholderView)
        placeholderView.pin(to: view)
    }
    
    override func prepare() {
        super.prepare()
        
        #warning("Remove")
        TaskScore.clear()
        
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
            
            self.screenView.reloadData()
            self.screenView.shallowReloadData()
        }
        
        PaidTaskBundlesManager.onLoadProductsInfo = {
            self.taskBundlesPurchaseStates = MainScreenDataLoader.getPurchaseStates(bundleIDs: self.taskBundles.map { $0.id })
            self.screenView.shallowReloadData()
        }
    }
    
}

extension MainScreen: MainScreenViewDelegate {
    
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
        let bundle = taskBundles[index]
        
        guard let purchaseState = taskBundlesPurchaseStates[bundle.id] else { return }
        
        switch purchaseState {
        case .free, .bought:
            showTasksBundle(bundle: bundle)
        case let .paid(price):
            showTasksBundlePurchse(bundle: bundle, price: price)
        default:
            return
        }
    }
    
    func didTapBuyTasksBundleButton(at index: Int) {
        didSelectTasksBundle(at: index)
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
    
}
