//
//  DecoderTaskScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore
import DetectItAPI

final class DecoderTaskScreen: Screen {
    
    // MARK: - Subviews
    
    let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    let contentContainer = StackViewController()
    
    let topPanel = TaskScreenTopPanel()
    let screenView = DecoderTaskScreenView()
    lazy var rateTaskViewController = RateTaskViewController(task: task, bundleID: bundle?.id)
    lazy var taskSharingViewController = TaskSharingViewController(task: task)
    
    let keyboardManager = KeyboardManager()
    var contentScrollViewOffset: CGFloat?
    
    let api = DetectItAPI()
    
    // MARK: - State
    
    let task: DecoderTask
    let bundle: TasksBundle.Info?
    let isTaskCompleted: Bool
    let onClose: (_ isCompleted: Bool) -> Void
    
    var encodedImage: UIImage?
    var encodedAudio: Data?
    
    var score: Int?
    var answer: String?
            
    // MARK: - Init
    
    init(
        task: DecoderTask,
        bundle: TasksBundle.Info?,
        isTaskCompleted: Bool,
        onClose: @escaping (_ isCompleted: Bool) -> Void
    ) {
        self.task = task
        self.bundle = bundle
        self.isTaskCompleted = isTaskCompleted
        self.onClose = onClose
        
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        keyboardManager.unsubscribe()
    }
    
    // MARK: - Overrides
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func loadView() {
        super.loadView()
        
        setupScreenLoadingView()
        setupContentView()
        setupViews()
        setupKeyboardManager()
    }
    
    override func prepare() {
        super.prepare()
                
        updateContentState(animated: false)
        
        loadTask()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(
            .cipherTask,
            parameters: [
                "task_id": task.id,
                "task_kind": task.kind.rawValue
            ]
        )
    }
    
    // MARK: - Actions
    
    func didTapEncodedPicture() {
        guard let image = encodedImage else { return }
        
        let imageViewer = PhotoViewerScreen(image: image, title: nil)
        
        present(imageViewer, animated: true, completion: nil)
    }
    
    func didTapAnswerButton() {
        view.endEditing(true)
        
        commitAnswer()
        
        scrollToResults()
        
        AppRateManager.shared.commitEvent()
        
        Analytics.log(
            "cipher_answer_sent",
            parameters: [
                "id": task.id,
                "answer": answer ?? ""
            ]
        )
    }
    
    @objc func onTapBackground() {
        view.endEditing(true)
    }
    
}

extension DecoderTaskScreen: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TaskScreenOpenTransitionAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TaskScreenCloseTransitionAnimator()
    }
    
}

extension DecoderTaskScreen: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view === gestureRecognizer.view
    }
    
}

extension DecoderTaskScreen {
    struct Constants {
        static let spacingBeforeScore = CGFloat(40)
        static let bottomInset = CGFloat(28)
    }
}
