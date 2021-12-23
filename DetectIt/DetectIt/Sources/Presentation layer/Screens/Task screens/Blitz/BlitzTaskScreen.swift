//
//  BlitzTaskScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 21.11.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItAPI
import DetectItCore

final class BlitzTaskScreen: Screen {
    
    // MARK: - Subviews
    
    let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    let contentContainer = StackViewController()
    
    let topPanel = TaskScreenTopPanel()
    lazy var screenView = BlitzTaskScreenView(delegate: self)
    lazy var rateTaskViewController = RateTaskViewController(task: task, bundleID: bundle?.id)
    lazy var taskSharingViewController = TaskSharingViewController(task: task)
    
    let keyboardManager = KeyboardManager()
    var contentScrollViewOffset: CGFloat?
    
    var api = DetectItAPI()
    
    // MARK: - State
    
    let task: BlitzTask
    let bundle: TasksBundle.Info?
    let isTaskCompleted: Bool
    let onClose: (_ isCompleted: Bool) -> Void
    
    var isDataLoaded = false
    
    var images: [String: UIImage] = [:]
    var audios: [String: Data] = [:]
    
    var answer = Answer() {
        didSet {
            answer.save(taskID: task.id, bundleID: bundle?.id)
            
            updateAnswerButtonState()
        }
    }
    
    var score: Int?
    
    var isSolved: Bool {
        score != nil
    }
    
    // MARK: - Init
    
    init(
        task: BlitzTask,
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
        
        contentContainer.place(into: self) { [unowned self] in
            $0.pin(to: self.view, insets: UIEdgeInsets(top: 0, left: .hInset, bottom: 0, right: -.hInset))
        }
        
        setupScreenLoadingView()
        setupViews()
        setupContentView()
        setupKeyboardManager()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.logScreenShow(
            .blitzTask,
            parameters: [
                "task_id": task.id,
                "task_kind": task.kind.rawValue
            ]
        )
    }
    
    // MARK: - Actions
    
    @objc func onTapBackground() {
        view.endEditing(true)
    }
    
}

extension BlitzTaskScreen: BlitzTaskScreenViewDelegate {
    
    func preposition() -> ProfilePrepositionCell.Model {
        ProfilePrepositionCell.Model(
            title: task.title,
            text: nil
        )
    }
    
    func numberOfCases() -> Int {
        isDataLoaded ? 1 : 0
    }
    
    func `case`(at index: Int) -> ProfileCaseCell.Model? {
        return ProfileCaseCell.Model(
            case: ProfileCaseCell.Model.CaseModel(
                title: nil,
                text: task.taskText
            ),
            evidence: nil
        )
    }
    
    func didSelectEvidence(at index: Int) {
        // There are no evidences in Blitz
    }
    
    func numberOfAttachments(in view: AttachmentsView) -> Int {
        guard isDataLoaded else { return 0 }
        
        switch view {
        case screenView.attachmentsView: return task.attachments?.count ?? 0
        case screenView.crimeDescriptionAttachmentsView: return task.crimeDescriptionAttachments?.count ?? 0
        default: return 0
        }
    }
    
    func attachment(at index: Int, in view: AttachmentsView) -> Any? {
        let attachment: ProfileTask.Attachment? = {
            switch view {
            case screenView.attachmentsView: return task.attachments?[index]
            case screenView.crimeDescriptionAttachmentsView: return task.crimeDescriptionAttachments?[index]
            default: return nil
            }
        }()
        guard let attachment = attachment else {
            return nil
        }
        
        switch attachment.kind {
        case .picture:
            guard let pictureName = attachment.pictureName, let picture = images[pictureName] else { return nil }
            
            return PhotoAttachmentCell.Model(title: attachment.title, photo: picture)
        case .audio:
            guard let audioName = attachment.audioFileName, let audio = audios[audioName] else { return nil }
            
            return AudioAttachmentCell.Model(title: attachment.title, audio: audio)
        }
    }
    
    func didSelectAttachment(at index: Int, in view: AttachmentsView) {
        let attachment: ProfileTask.Attachment? = {
            switch view {
            case screenView.attachmentsView: return task.attachments?[index]
            case screenView.crimeDescriptionAttachmentsView: return task.crimeDescriptionAttachments?[index]
            default: return nil
            }
        }()
        guard let attachment = attachment, let picture = attachment.pictureName, let image = images[picture] else {
            return
        }
        
        let imageViewer = PhotoViewerScreen(image: image, title: attachment.title)
        
        present(imageViewer, animated: true, completion: nil)
    }
    
    func didTapAnswerButton() {
        finish()
    }
    
    func numberOfQuestions() -> Int {
        1
    }
    
    func question(at index: Int) -> (question: Any, isCorrect: Bool?)? {
        let question = task.question
        
        if question.number != nil {
            let model = ProfileTaskNumberQuestionCell.Model(
                question: question.title,
                answer: answer.answer?.answer.int,
                onChangeAnswer: { [unowned self] answer in
                    if let answer = answer {
                        self.answer.set(
                            answer: .init(questingID: question.id, answer: .int(answer))
                        )
                    } else {
                        self.answer.delete()
                    }
                }
            )
            let isCorrect = isSolved ? answer.answer.map { question.compare(with: $0.answer) } : nil
            
            return (model, isCorrect)
        } else if question.exactAnswer != nil {
            let userAnswer = answer.answer
            
            let model = ProfileTaskExactAnswerQuestionCell.Model(
                question: question.title,
                answer: userAnswer?.answer.string,
                onChangeAnswer: { [unowned self] answer in
                    if !answer.isEmpty {
                        self.answer.set(
                            answer: .init(questingID: question.id, answer: .string(answer))
                        )
                    } else {
                        self.answer.delete()
                    }
                }
            )
            let isCorrect = isSolved ? userAnswer.map { question.compare(with: $0.answer) } : nil
            
            return (model, isCorrect)
        } else if let variantsQuestion = question.variant {
            let answer = answer.answer?.answer.string
            let selectedVariantIndex = variantsQuestion.variants.firstIndex(where: { $0.id == answer })
            let model = ProfileTaskVariantsQuestionCell.Model(
                question: question.title,
                variants: variantsQuestion.variants.map { $0.text },
                selectedVariantIndex: selectedVariantIndex,
                onSelectVariant: { [unowned self] index in
                    self.answer.set(
                        answer: .init(questingID: question.id, answer: .string(variantsQuestion.variants[index].id))
                    )
                }
            )
            let isCorrect = isSolved ? self.answer.answer.map { question.compare(with: $0.answer) } : nil
            
            return (model, isCorrect)
        } else if question.boolAnswer != nil {
            let model = ProfileTaskBoolAnswerQuestionCell.Model(
                question: question.title,
                answer: answer.answer?.answer.bool,
                onSelectAnswer: { [unowned self] answer in
                    self.answer.set(
                        answer: .init(questingID: question.id, answer: .bool(answer))
                    )
                }
            )
            let isCorrect = isSolved ? answer.answer.map { question.compare(with: $0.answer) } : nil
            
            return (model, isCorrect)
        } else {
            return nil
        }
    }
    
    func answerModel() -> ProfileTaskAnswerCell.Model? {
        let question = task.question
        let answer: String = {
            if let number = question.number?.correctNumber {
                return "\(number)"
            } else if let string = question.exactAnswer?.answer {
                return string
            } else if let variantID = question.variant?.correctVariantID {
                return question.variant?.variants.first(where: { $0.id == variantID })?.text ?? ""
            } else if let bool = question.boolAnswer?.answer {
                return bool ? "profile_task_screen_answer_yes_title".localized : "profile_task_screen_answer_no_title".localized
            } else {
                return ""
            }
        }()
        
        return ProfileTaskAnswerCell.Model(
            question: "\(question.title) (\(Plurals.score(question.score)))",
            answer: answer
        )
    }
    
    func didTapGetStatusButton() {
        let screen = FullVersionPurchaseScreen()
        screen.presentationController?.delegate = self
        
        present(screen, animated: true, completion: nil)
        
        Analytics.logButtonTap(title: "blitz_task_screen_get_status_button_title".localized, screen: .blitzTask)
    }
    
}

extension BlitzTaskScreen: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TaskScreenOpenTransitionAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TaskScreenCloseTransitionAnimator()
    }
    
}

extension BlitzTaskScreen: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        updateContentState(animated: false)
    }
    
}

extension BlitzTaskScreen: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view === gestureRecognizer.view
    }
    
}

extension BlitzTaskScreen {
    struct Constants {
        static let spacingBeforeScore = CGFloat(40)
        static let bottomInset = CGFloat(28)
    }
}
