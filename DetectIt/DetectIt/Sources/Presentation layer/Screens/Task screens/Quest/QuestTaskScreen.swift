//
//  QuestTaskScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore
import DetectItAPI

final class QuestTaskScreen: Screen {
    
    // MARK: - Subviews
    
    let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    let contentContainer = StackViewController()
    
    let topPanel = TaskScreenTopPanel()
    lazy var screenView = QuestTaskScreenView(delegate: self)
    lazy var rateTaskViewController = RateTaskViewController(task: state.task, bundleID: state.bundle?.id)
        
    var api = DetectItAPI()
    
    // MARK: - State
    
    var state: State
    
    // MARK: - Init
    
    init(task: QuestTask, bundle: TasksBundle.Info?) {
        self.state = State(task: task, bundle: bundle)
        
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Overrides
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func loadView() {
        super.loadView()
        
        contentContainer.place(into: self) {
            $0.pin(to: self.view, insets: UIEdgeInsets(top: 0, left: .hInset, bottom: 0, right: -.hInset))
        }
        
        setupScreenLoadingView()
        setupViews()
        setupContentView()
    }
    
    override func prepare() {
        super.prepare()
        
        screenPlaceholderView.configure(
            title: "network_error_title".localized,
            message: "network_error_message".localized,
            onRetry: { [unowned self] in
                self.loadTask()
            },
            onClose: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            }
        )
        
        loadTask()
        
        screenView.setPreposition(
            .init(
                title: state.task.title,
                text: state.task.preposition
            )
        )
        screenView.setChapters(
            state.shownChapters.map(
                mapChapterEntityToModel
            )
        )

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(.questTask)
    }
    
    // MARK: - Actions
    
    @objc func onTapBackground() {
        view.endEditing(true)
    }
    
}

extension QuestTaskScreen: QuestTaskScreenViewDelegate {
    
    func didSelectRoute(chapterIndex: Int, answerIndex: Int) {
        guard let currentChapter = state.currentChapter else { return }
        
        let selectedAction = currentChapter.actions[answerIndex]
        
        let nextChapter = selectedAction.targetChapterID.flatMap { targetChapterID in
            state.task.chapters.first { chapter in
                chapter.id == targetChapterID
            }
        }
        let ending = selectedAction.targetEndingID.flatMap { targetEndingID in
            state.task.endings.first { ending in
                ending.id == targetEndingID
            }
        }
        
        if state.answer == nil {
            state.answer = .init(routes: [], ending: nil)
        }
        
        if let nextChapter = nextChapter {
            state.answer?.routes.append(
                .init(
                    fromChapter: currentChapter.id,
                    toChapter: nextChapter.id
                )
            )
            
            screenView.updateChapter(mapChapterEntityToModel(entity: currentChapter), at: state.shownChapters.count - 2)
            screenView.appendChapter(mapChapterEntityToModel(entity: nextChapter))
            
            commitAnswers()
        } else if let ending = ending {
            state.answer?.ending = .init(
                fromChapter: currentChapter.id,
                toChapter: ending.id
            )
                        
            screenView.updateChapter(mapChapterEntityToModel(entity: currentChapter), at: state.shownChapters.count - 1)
            
            finish()
        }
    }
    
}

extension QuestTaskScreen: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TaskScreenOpenTransitionAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TaskScreenCloseTransitionAnimator()
    }
    
}

extension QuestTaskScreen: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        updateContentState(animated: false)
    }
    
}

extension QuestTaskScreen: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view === gestureRecognizer.view
    }
    
}

extension QuestTaskScreen {
    struct Constants {
        static let spacingBeforeScore = CGFloat(40)
        static let bottomInset = CGFloat(28)
    }
}

