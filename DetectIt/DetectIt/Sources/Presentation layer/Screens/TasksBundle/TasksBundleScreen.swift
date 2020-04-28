//
//  TasksBundleScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 02/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class TasksBundleScreen: Screen {
    
    private var screenView: TasksBundleScreenView {
        view as! TasksBundleScreenView
    }
    
    private let placeholderView = ScreenPlaceholderView(isInitiallyHidden: true)
    
    // MARK: - State
    
    private let tasksBundle: TasksBundle.Info
    private let tasksBundleImage: UIImage
    
    private var bundle: TasksBundle?
    
    private var sections: [SectionModel] = []
    
    var purchaseState: TasksBundlePurchaseState {
        PaidTaskBundlesManager.tasksBundlePurchaseState(id: tasksBundle.id)
    }
    
    // MARK: - Init
    
    init(tasksBundle: TasksBundle.Info, image: UIImage) {
        self.tasksBundle = tasksBundle
        self.tasksBundleImage = image
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Overrides
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .fade }
    
    override func loadView() {
        view = TasksBundleScreenView(delegate: self)
        
        view.clipsToBounds = true
        
        setupPlaceholder()
    }
    
    override func prepare() {
        super.prepare()
        
        PaidTaskBundlesManager.subscribeToProductsInfoLoading(self) {
            self.refresh()
        }
    }
    
    override func refresh() {
        super.refresh()
        
        guard bundle == nil else {
            reloadHeader(bundle: bundle!)
            reloadContent(bundle: bundle!)
            
            return
        }
        
        placeholderView.setVisible(true, animated: false)
        
        TasksBundle.load(bundleID: tasksBundle.id) { [weak self] bundle in
            guard let self = self else { return }
            
            self.bundle = bundle
            
            if let bundle = bundle {
                self.reloadHeader(bundle: bundle)
                self.reloadContent(bundle: bundle)
                
                self.placeholderView.setVisible(false, animated: true)
            }
        }
    }
    
}

// MARK: - TasksBundleScreenViewDelegate

extension TasksBundleScreen: TasksBundleScreenViewDelegate {
    
    func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections() -> Int {
        sections.count
    }
    
    func numberOfTasks(in section: Int) -> Int {
        sections[section].1.count
    }
    
    func sectionHeader(for section: Int) -> String? {
        sections[section].0.title
    }
    
    func task(at index: Int, in section: Int) -> TasksBundleScreenTaskCell.Model? {
        sections[section].1[index]
    }
    
    func didSelectTask(at index: Int, in section: Int) {
        guard let bundle = bundle else { return }
        
        let section = sections[section].0
        
        let task: Task = {
            switch section {
            case .ciphers:
                return bundle.decoderTasks[index]
            case .profiles:
                return bundle.profileTasks[index]
            case .quests:
                return bundle.questTasks[index]
            }
        }()
        
        TaskScreenRoute(root: self).show(task: task, bundle: bundle.info)

    }
    
    func didTapBuyButton() {
        showLoadingHUD(title: nil)
        
        PaidTaskBundlesManager.purchase(bundleID: tasksBundle.id) { [weak self] error in
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
    
}

private extension TasksBundleScreen {
    
    func setupPlaceholder() {
        view.addSubview(placeholderView)
        placeholderView.pin(to: view)
    }
    
    func reloadHeader(bundle: TasksBundle) {
        let score = TaskScore.get(bundleID: bundle.info.id) ?? 0
        let totalScore = "\(score)/\(bundle.maxScore)"
        
        screenView.configureHeader(
            model: TasksBundleScreenHeaderView.Model(
                image: tasksBundleImage,
                title: tasksBundle.title,
                totalScore: totalScore,
                description: tasksBundle.description,
                isPaid: !purchaseState.isAvailable,
                price: PaidTaskBundlesManager.price(bundleID: tasksBundle.id)
            )
        )
    }
    
    func reloadContent(bundle: TasksBundle) {
        sections = self.makeSections(bundle: bundle)
        screenView.reloadContent()
    }
    
}
