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
import DetectItAPI

final class TasksBundleScreen: Screen {
    
    private lazy var screenView = TasksBundleScreenView(delegate: self)
    
    private let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    private let api = DetectItAPI()
    
    // MARK: - State
    
    private let tasksBundle: TasksBundle.Info
    private let tasksBundleImageName: String
    
    private var bundle: TasksBundle?
    
    private var sections: [SectionModel] = []
    
    // MARK: - Init
    
    init(tasksBundle: TasksBundle.Info, tasksBundleImageName: String) {
        self.tasksBundle = tasksBundle
        self.tasksBundleImageName = tasksBundleImageName
        
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
        view = screenView
        
        view.clipsToBounds = true
        
        setupScreenLoadingView()
    }
    
    override func prepare() {
        super.prepare()
        
        FullVersionManager.subscribeToProductInfoLoading(self) {
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
        
        loadTasksBundle()
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
    
}

private extension TasksBundleScreen {
    
    func setupScreenLoadingView() {
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
    }
    
    func loadTasksBundle() {
        screenLoadingView.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: false)
        
        api.obtain(
            TasksBundle.self,
            target: .tasksBundle(bundleID: tasksBundle.id),
            cacheKey: Cache.Key(["tasks_bundle", tasksBundle.id])
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(bundle):
                self.bundle = bundle
                
                self.screenLoadingView.setVisible(false, animated: true)
                
                self.reloadHeader(bundle: bundle)
                self.reloadContent(bundle: bundle)
            case .failure:
                self.screenPlaceholderView.setVisible(true, animated: false)
                self.screenLoadingView.setVisible(false, animated: true)
                self.screenPlaceholderView.configure(
                    title: "network_error_title".localized,
                    message: "network_error_message".localized,
                    onRetry: { [unowned self] in self.loadTasksBundle() },
                    onClose: { [unowned self] in self.dismiss(animated: true, completion: nil) }
                )
            }
        }
    }
    
    func reloadHeader(bundle: TasksBundle) {
        let score = TaskScore.get(bundleID: bundle.info.id) ?? 0
        let totalScore = "\(score)/\(bundle.maxScore)"
        
        screenView.configureHeader(
            model: TasksBundleScreenHeaderView.Model(
                image: tasksBundleImageName,
                title: tasksBundle.title,
                totalScore: totalScore,
                description: tasksBundle.description,
                action: tasksBundle.action.map { action in
                    TasksBundleScreenHeaderView.Model.Action(
                        title: action.title,
                        titleColor: UIColor(action.titleColor, defaultColor: .white),
                        backgroundColor: UIColor(action.backgroundColor, defaultColor: .darkGray),
                        action: {
                            guard let url = URL(string: action.link) else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    )
                },
                isPaid: false,
                price: nil
            )
        )
    }
    
    func reloadContent(bundle: TasksBundle) {
        sections = self.makeSections(bundle: bundle)
        screenView.reloadContent()
    }
    
}
