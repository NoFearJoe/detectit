//
//  ProfileTaskScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore
import DetectItAPI

final class ProfileTaskScreen: Screen {
    
    // MARK: - Subviews
    
    let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    let contentContainer = StackViewController()
    
    let closeButton = SolidButton.closeButton()
    let helpButton = SolidButton.helpButton()
    
    lazy var screenView = ProfileTaskScreenView(delegate: self)
    
    let keyboardManager = KeyboardManager()
    var contentScrollViewOffset: CGFloat?
    
    var api = DetectItAPI()
    
    // MARK: - State
    
    let task: ProfileTask
    let bundle: TasksBundle.Info?
    
    var isDataLoaded = false
    
    var images: [String: UIImage] = [:]
    var audios: [String: Data] = [:]
    
    var answers = Answers() {
        didSet {
            TaskAnswer.set(answers: answers.answers, profileTaskID: task.id, bundleID: bundle?.id)
            
            updateAnswerButtonState()
        }
    }
    
    var score: Int?
    
    var isSolved: Bool {
        score != nil
    }
    
    // MARK: - Init
    
    init(task: ProfileTask, bundle: TasksBundle.Info?) {
        self.task = task
        self.bundle = bundle
        
        super.init(nibName: nil, bundle: nil)
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
        
        contentContainer.place(into: self) {
            $0.pin(to: self.view, insets: UIEdgeInsets(top: 0, left: .hInset, bottom: 0, right: -.hInset))
        }
        
        setupScreenLoadingView()
        setupViews()
        setupContentView()
        setupKeyboardManager()
        
        isStatusBarBlurred = true
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
    
    // MARK: - Actions
    
    @objc func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapHelpButton() {
        User.shared.isProfileHelpShown = true
        
        helpButton.isHidden = true
        
        present(HelpScreen(taskKind: task.kind), animated: true, completion: nil)
    }
    
    @objc func onTapBackground() {
        view.endEditing(true)
    }
    
}

extension ProfileTaskScreen: ProfileTaskScreenViewDelegate {
    
    func preposition() -> ProfilePrepositionCell.Model {
        ProfilePrepositionCell.Model(
            title: task.title,
            text: task.preposition
        )
    }
    
    func numberOfCases() -> Int {
        isDataLoaded ? task.cases.count : 0
    }
    
    func `case`(at index: Int) -> ProfileCaseCell.Model? {
        let `case` = task.cases[index]
        
        return ProfileCaseCell.Model(
            case: ProfileCaseCell.Model.CaseModel(
                title: `case`.title,
                text: `case`.text
            ),
            evidence: `case`.evidencePicture.map {
                PhotoCardView.Model(
                    photo: images[$0.pictureName] ?? UIImage(),
                    title: $0.title
                )
            }
        )
    }
    
    func didSelectEvidence(at index: Int) {
        guard let picture = task.cases[index].evidencePicture, let image = images[picture.pictureName] else {
            return
        }
        
        let imageViewer = PhotoViewerScreen(image: image, title: picture.title)
        
        present(imageViewer, animated: true, completion: nil)
    }
    
    func numberOfAttachments() -> Int {
        isDataLoaded ? (task.attachments?.count ?? 0) : 0
    }
    
    func attachment(at index: Int) -> Any? {
        guard let attachment = task.attachments?[index] else {
            return nil
        }
        
        switch attachment.kind {
        case .picture:
            guard let pictureName = attachment.pictureName, let picture = images[pictureName] else { return nil }
            
            return ProfilePhotoAttachmentCell.Model(title: attachment.title, photo: picture)
        case .audio:
            guard let audioName = attachment.audioFileName, let audio = audios[audioName] else { return nil }
            
            return ProfileAudioAttachmentCell.Model(title: attachment.title, audio: audio)
        }
    }
    
    func didSelectAttachment(at index: Int) {
        guard let attachment = task.attachments?[index], let picture = attachment.pictureName, let image = images[picture] else {
            return
        }
        
        let imageViewer = PhotoViewerScreen(image: image, title: attachment.title)
        
        present(imageViewer, animated: true, completion: nil)
    }
    
    func didTapAnswerButton() {
        finish()
    }
    
    func numberOfQuestions() -> Int {
        isDataLoaded ? task.questions.count : 0
    }
    
    func question(at index: Int) -> (question: Any, isCorrect: Bool?)? {
        let question = task.questions[index]
        
        if question.number != nil {
            let model = ProfileTaskNumberQuestionCell.Model(
                question: question.title,
                answer: answers.get(questionID: question.id)?.answer.int,
                onChangeAnswer: { [unowned self] answer in
                    if let answer = answer {
                        self.answers.set(
                            answer: .int(answer),
                            questionID: question.id
                        )
                    } else {
                        self.answers.delete(questionID: question.id)
                    }
                }
            )
            let isCorrect = isSolved ? answers.get(questionID: question.id).map { question.compare(with: $0.answer) } : nil
            
            return (model, isCorrect)
        } else if question.exactAnswer != nil {
            let userAnswer = answers.get(questionID: question.id)
            
            let model = ProfileTaskExactAnswerQuestionCell.Model(
                question: question.title,
                answer: userAnswer?.answer.string,
                onChangeAnswer: { [unowned self] answer in
                    if !answer.isEmpty {
                        self.answers.set(
                            answer: .string(answer),
                            questionID: question.id
                        )
                    } else {
                        self.answers.delete(questionID: question.id)
                    }
                }
            )
            let isCorrect = isSolved ? userAnswer.map { question.compare(with: $0.answer) } : nil
            
            return (model, isCorrect)
        } else if let variantsQuestion = question.variant {
            let answer = answers.get(questionID: question.id)?.answer.string
            let selectedVariantIndex = variantsQuestion.variants.firstIndex(where: { $0.id == answer })
            let model = ProfileTaskVariantsQuestionCell.Model(
                question: question.title,
                variants: variantsQuestion.variants.map { $0.text },
                selectedVariantIndex: selectedVariantIndex,
                onSelectVariant: { [unowned self] index in
                    self.answers.set(
                        answer: .string(variantsQuestion.variants[index].id),
                        questionID: question.id
                    )
                }
            )
            let isCorrect = isSolved ? answers.get(questionID: question.id).map { question.compare(with: $0.answer) } : nil
            
            return (model, isCorrect)
        } else if question.boolAnswer != nil {
            let model = ProfileTaskBoolAnswerQuestionCell.Model(
                question: question.title,
                answer: answers.get(questionID: question.id)?.answer.bool,
                onSelectAnswer: { [unowned self] answer in
                    self.answers.set(
                        answer: .bool(answer),
                        questionID: question.id
                    )
                }
            )
            let isCorrect = isSolved ? answers.get(questionID: question.id).map { question.compare(with: $0.answer) } : nil
            
            return (model, isCorrect)
        } else {
            return nil
        }
    }
    
    func numberOfAnswers() -> Int {
        task.questions.count
    }
    
    func answer(at index: Int) -> ProfileTaskAnswerCell.Model? {
        let question = task.questions[index]
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
    }
    
}

extension ProfileTaskScreen: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        updateContentState(animated: false)
    }
    
}

extension ProfileTaskScreen: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view === gestureRecognizer.view
    }
    
}

extension ProfileTaskScreen {
    struct Constants {
        static let spacingBeforeScore = CGFloat(40)
        static let bottomInset = CGFloat(20)
    }
}
