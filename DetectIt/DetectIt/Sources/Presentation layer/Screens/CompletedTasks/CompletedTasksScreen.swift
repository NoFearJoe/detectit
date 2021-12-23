//
//  CompletedTasksScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 16.06.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItAPI
import DetectItCore

final class CompletedTasksScreen: Screen {
    
    private let topPanel = TaskScreenTopPanel()
    private let titleLabel = UILabel()
    private lazy var screenView = MainScreenView(sections: [.tasks], delegate: self)
    
    private let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    private let api = DetectItAPI()
    
    private var feedItems: [Feed.Item] = []
    private var tasksScoreCache = [String: Int]()
    
    // MARK: - Overrides
    
    override func loadView() {
        view = screenView
        
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
        
        view.addSubview(topPanel)
        
        topPanel.notesButton.isHidden = true
        topPanel.shareButton.isHidden = true
        topPanel.onClose = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        
        topPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topPanel.topAnchor.constraint(equalTo: view.topAnchor),
            topPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        topPanel.addSubview(titleLabel)
        titleLabel.text = "completed_tasks_screen_title".localized
        titleLabel.textColor = .white
        titleLabel.font = .heading2
        titleLabel.adjustsFontSizeToFitWidth = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: topPanel.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: topPanel.closeButton.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: topPanel.closeButton.leadingAnchor, constant: -8)
        ])
    }
    
    override func refresh() {
        super.refresh()
        
        loadFeed()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(.completedTasks)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.screenView.reloadData()
        })
    }
    
}

extension CompletedTasksScreen: MainScreenViewDelegate {
    
    func header() -> MainScreenHeaderView.Model? { nil }
    func didTapProfileButton() {}
    func filters() -> [MainScreenFiltersView.Model] { [] }
    func didSelectFilter(at index: Int) {}
    func banner() -> MainScreenBannerCell.Model? { nil }
    func didSelectBanner() {}
    func didCloseBanner() {}
    func shouldShowCompletedTasksCell() -> Bool { false }
    func didSelectCompletedTasksCell() {}
    
    func numberOfFeedItems() -> Int {
        if feedItems.isEmpty == true {
            return 1
        } else {
            return feedItems.count
        }
    }
    
    func feedItem(at index: Int) -> Any? {
        if feedItems.isEmpty {
            return MainScreenPlaceholderCell.Model(message: "completed_tasks_screen_empty_placeholder_message".localized)
        }
        
        guard let item = feedItems.item(at: index) else { return nil }
        
        switch item.kind {
        case .profile, .blitz, .cipher, .quest:
            let kind = TaskKind(rawValue: item.kind.rawValue)
            let difficulty = TaskDifficulty(rawValue: item.difficulty)
            let score = tasksScoreCache[item.id]
            return MainScreenTaskCell.Model(
                backgroundImagePath: item.picture,
                kindIcon: kind?.icon,
                kind: kind?.title ?? "",
                title: item.title,
                description: item.subtitle ?? "",
                difficulty: difficulty.localizedTitle,
                difficultyColor: difficulty.color,
                score: score.map { ScoreStringBuilder.makeScoreString(score: $0, max: item.maxScore) },
                scoreColor: UIColor.score(value: score, max: item.maxScore),
                rating: item.rating,
                isLocked: !FullVersionManager.hasBought && item.difficulty >= 3,
                isFocused: false
            )
        case .bundle:
            return MainScreenTasksBundleCell.Model(
                backgroundImagePath: item.picture,
                title: item.title,
                description: item.subtitle ?? ""
            )
        }
    }
    
    func didSelectFeedItem(at index: Int) {
        guard let item = feedItems.item(at: index) else { return }
        
        switch item.kind {
        case .cipher:
            guard let cipher = item.cipher else { return }
            TaskScreenRoute(root: self).show(task: cipher, bundle: nil, isTaskCompleted: item.completed)
        case .profile:
            guard let profile = item.profile else { return }
            TaskScreenRoute(root: self).show(task: profile, bundle: nil, isTaskCompleted: item.completed)
        case .blitz:
            guard let blitz = item.blitz else { return }
            TaskScreenRoute(root: self).show(task: blitz, bundle: nil, isTaskCompleted: item.completed)
        case .quest:
            guard let quest = item.quest else { return }
            TaskScreenRoute(root: self).show(task: quest, bundle: nil, isTaskCompleted: item.completed)
        case .bundle:
            guard let tasksBundle = item.bundle else { return }
            showTasksBundle(bundle: tasksBundle, imageName: item.picture)
        }
        
        Analytics.log(
            "task_selected",
            parameters: [
                "id": item.id,
                "kind": item.kind.rawValue,
                "difficulty": item.difficulty,
                "score": item.score ?? 0,
                "screen": Analytics.Screen.main.rawValue
            ]
        )
    }
    
    func numberOfActions() -> Int { 0 }
    func action(at index: Int) -> String? { nil }
    func didSelectAction(at index: Int) {}
    
}

private extension CompletedTasksScreen {
    
    func loadFeed() {
        if feedItems.isEmpty {
            screenLoadingView.setVisible(true, animated: false)
            screenPlaceholderView.setVisible(false, animated: false)
        }
                
       api.obtain(
            Feed.self,
            target: .completedTasks,
            cacheKey: Cache.Key("completedTasks")
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(feed):
                self.screenLoadingView.setVisible(false, animated: true)
                
                self.feedItems = feed.items
                
                self.tasksScoreCache.removeAll()
                self.feedItems.forEach {
                    self.tasksScoreCache[$0.id] =
                        $0.score ??
                        TaskScore.get(
                            id: $0.id,
                            taskKind: TaskKind(rawValue: $0.kind.rawValue) ?? .cipher,
                            bundleID: $0.bundle?.id
                        )
                }
                
                self.screenView.reloadData()
            case .failure:
                guard self.feedItems.isEmpty else { return }
                
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
    
}
