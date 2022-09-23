//
//  TasksCompilationScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 01.02.2022.
//  Copyright © 2022 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItAPI
import DetectItCore

final class TasksCompilationScreen: Screen {
    
    private let topPanel = ScreenHeaderView()
    private let titleLabel = UILabel()
    private lazy var screenView = MainScreenView(sections: [.tasks], delegate: self)
    
    private let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    private let api = DetectItAPI()
    
    private var compilationDetails: CompilationDetails?
    private var tasksScoreCache = [String: Int]()
    
    let compilation: Feed.Compilation
    
    init(compilation: Feed.Compilation) {
        self.compilation = compilation

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Overrides
    
    override func loadView() {
        view = screenView
        
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
        
        view.addSubview(topPanel)

        topPanel.titleLabel.text = compilation.title
        topPanel.onClose = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }

        topPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topPanel.topAnchor.constraint(equalTo: view.topAnchor),
            topPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func refresh() {
        super.refresh()
        
        loadCompilation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(
            .tasksCompilation,
            parameters: [
                "compilationID": compilation.id,
                "compilationTitle": compilation.title
            ]
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        screenView.setTopInset(topPanel.bounds.height - view.safeAreaInsets.top + 4)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.screenView.reloadData()
        })
    }
    
}

extension TasksCompilationScreen: MainScreenViewDelegate {
    
    func header() -> MainScreenHeaderView.Model? { nil }
    func didTapProfileButton() {}
    func filters() -> [MainScreenFiltersView.Model] { [] }
    func didSelectFilter(at index: Int) {}
    func banner() -> MainScreenBannerCell.Model? { nil }
    func didSelectBanner() {}
    func didCloseBanner() {}
    func shouldShowCompletedTasksCell() -> Bool { false }
    func didSelectCompletedTasksCell() {}
    func numberOfCompilations() -> Int { 0 }
    func compilations() -> [MainScreenCompilationCell.Model] { [] }
    func didSelectCompilation(at index: Int) {}
    
    func numberOfFeedItems() -> Int {
        if compilationDetails == nil || compilationDetails?.tasks.isEmpty == true {
            return 1
        } else {
            return compilationDetails?.tasks.count ?? 0
        }
    }
    
    func feedItem(at index: Int) -> Any? {
        if compilationDetails == nil || compilationDetails?.tasks.isEmpty == true {
            return MainScreenPlaceholderCell.Model(message: "tasks_compilation_screen_empty_placeholder_message".localized)
        }
        
        guard let item = compilationDetails?.tasks.item(at: index) else { return nil }
        
        switch item.kind {
        case .profile, .blitz, .cipher, .quest:
            let kind = TaskKind(rawValue: item.kind.rawValue)
            let difficulty = TaskDifficulty(rawValue: item.difficulty)
            let score = tasksScoreCache[item.id]
            return MainScreenTaskCell.Model(
                id: item.id,
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
        guard let item = compilationDetails?.tasks.item(at: index) else { return }
        
        switch item.kind {
        case .cipher:
            guard let cipher = item.cipher else { return }
            TaskScreenRoute(root: self)
                .show(task: cipher, bundleID: item.parentBundleID, isTaskCompleted: item.completed, onClose: { _ in })
        case .profile:
            guard let profile = item.profile else { return }
            TaskScreenRoute(root: self)
                .show(task: profile, bundleID: item.parentBundleID, isTaskCompleted: item.completed, onClose: { _ in })
        case .blitz:
            guard let blitz = item.blitz else { return }
            TaskScreenRoute(root: self)
                .show(task: blitz, bundleID: item.parentBundleID, isTaskCompleted: item.completed, onClose: { _ in })
        case .quest:
            guard let quest = item.quest else { return }
            TaskScreenRoute(root: self)
                .show(task: quest, bundleID: item.parentBundleID, isTaskCompleted: item.completed, onClose: { _ in })
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
                "screen": Analytics.Screen.tasksCompilation.rawValue,
                "compilationID": compilation.id
            ]
        )
    }
    
    func numberOfActions() -> Int { 0 }
    func action(at index: Int) -> String? { nil }
    func didSelectAction(at index: Int) {}
    
}

private extension TasksCompilationScreen {
    
    func loadCompilation() {
        if compilationDetails == nil || compilationDetails?.tasks.isEmpty == true {
            screenLoadingView.setVisible(true, animated: false)
            screenPlaceholderView.setVisible(false, animated: false)
        }
                
       api.obtain(
            CompilationDetails.self,
            target: .compilation(id: compilation.id),
            cacheKey: Cache.Key("compilation_\(compilation.id)")
        ) { [weak self] result in
            guard let self = self else { return }
            
//            switch result {
//            case let .success(compilation):
//                self.screenLoadingView.setVisible(false, animated: true)
//
//                self.compilationDetails = compilation
//
//                self.tasksScoreCache.removeAll()
//                self.compilationDetails?.tasks.forEach {
//                    self.tasksScoreCache[$0.id] =
//                        $0.score ??
//                        TaskScore.get(
//                            id: $0.id,
//                            taskKind: TaskKind(rawValue: $0.kind.rawValue) ?? .cipher,
//                            bundleID: $0.bundle?.id
//                        )
//                }
//
//                self.screenView.reloadData()
//            case .failure:
//                guard self.compilationDetails == nil || self.compilationDetails?.tasks.isEmpty == true else { return }
                
                self.screenPlaceholderView.setVisible(true, animated: false)
                self.screenLoadingView.setVisible(false, animated: true)
                self.screenPlaceholderView.configure(
                    title: "network_error_title".localized,
                    message: "network_error_message".localized,
                    onRetry: { [unowned self] in self.loadCompilation() },
                    onClose: nil,
                    onReport: { [unowned self] in ReportProblemRoute(root: self).show() }
                )
                
                Analytics.logScreenError(screen: .tasksCompilation)
//            }
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

extension TasksCompilationScreen: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        screenView.reloadData()
    }
    
}
