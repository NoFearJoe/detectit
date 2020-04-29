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

final class ProfileTaskScreen: Screen {
    
    // MARK: - Subviews
    
    private let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    private let contentContainer = StackViewController()
    
    private let closeButton = SolidButton.closeButton()
    private let helpButton = SolidButton.helpButton()
    
    private lazy var screenView = ProfileTaskScreenView(delegate: self)
    
    private let keyboardManager = KeyboardManager()
    private var contentScrollViewOffset: CGFloat?
    
    // MARK: - State
    
    private let task: ProfileTask
    private let bundle: TasksBundle.Info?
    
    private var isDataLoaded = false
    
    private var images: [String: UIImage] = [:]
    
    private var answers = Answers() {
        didSet {
            TaskAnswer.set(answers: answers.answers, profileTaskID: task.id, bundleID: bundle?.id)
            
            updateAnswerButtonState()
        }
    }
    
    private var score: Int?
    
    private var isSolved: Bool {
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
        
        answers.load(taskID: task.id, bundleID: bundle?.id)
        score = TaskScore.get(id: task.id, taskKind: task.kind, bundleID: bundle?.id)
        
        screenLoadingView.setVisible(true, animated: false)
        updateContentState(animated: false)
        
        ProfileTaskScreenDataLoader.loadData(task: task) { [weak self] images in
            guard let self = self else { return }
            
            self.images = images
            self.isDataLoaded = true
            
            self.screenView.reloadContent()
            
            self.screenLoadingView.setVisible(false, animated: true)
        }
    }
    
    // MARK: - Business logic
    
    func updateAnswerButtonState() {
        screenView.answerButton.isEnabled = answers.count == task.questions.count && score == nil
    }
    
    func finish() {
        view.endEditing(true)
        
        commitAnswers()

        updateContentState(animated: true)
        
        scrollToResults()
    }
    
    func commitAnswers() {
        let totalScore = answers.answers.reduce(0) { result, answer in
            guard let question = task.questions.first(where: { $0.id == answer.questionID }) else {
                return result
            }
            
            let isCorrectAnswer = question.compare(with: answer.answer)
            let score = isCorrectAnswer ? question.score : 0
            
            return result + score
        }
        
        TaskScore.set(value: totalScore, id: task.id, taskKind: task.kind, bundleID: bundle?.id)
        TaskAnswer.set(answers: answers.answers, profileTaskID: task.id, bundleID: bundle?.id)
        
        score = totalScore
    }
    
    func updateContentState(animated: Bool) {
        contentContainer.setChildHidden(screenView.answerButton, hidden: isSolved, animated: false)
        contentContainer.setChildHidden(screenView.scoreLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.crimeDescriptionLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.answersView, hidden: !isSolved, animated: animated, animationDuration: 2)
        
        screenView.scoreLabel.text = score.map { "\($0)/\(task.maxScore)" }
        screenView.scoreLabel.textColor = .score(value: score, max: task.maxScore, defaultColor: .white)
        screenView.crimeDescriptionLabel.attributedText = task.crimeDescription.readableAttributedText()
        
        guard isSolved else { return }
        
        task.questions.enumerated().forEach { index, question in
            let answer = answers.get(questionID: question.id)
            let isCorrect = answer.map { question.compare(with: $0.answer) } ?? false
            let cell = screenView.reportView.getAnswerCell(at: index)
            
            cell?.setEnabled(!isSolved)
            cell?.highlight(isCorrect: isCorrect, animated: animated, animationDuration: 2)
        }
    }
    
    func scrollToResults() {
        view.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let minY = self.screenView.scoreLabel.frame.minY
            let maxY = self.screenView.answersView.frame.maxY
            let targetY = maxY - minY > self.view.bounds.height ? minY : max(0, maxY - self.view.bounds.height)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.contentContainer.scrollView.contentOffset = CGPoint(x: 0, y: targetY)
            }) { _ in
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapHelpButton() {
        User.shared.isProfileHelpShown = true
        
        helpButton.isHidden = true
        
        present(HelpScreen(taskKind: task.kind), animated: true, completion: nil)
    }
    
    @objc private func onTapBackground() {
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
            case: PaperSheetView.Model(
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
            return nil
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
                return bool ? "Да" : "Нет"
            } else {
                return ""
            }
        }()
        
        return ProfileTaskAnswerCell.Model(
            question: "\(question.title) (\(Plurals.score(question.score)))",
            answer: answer
        )
    }
    
}

// MARK: - Setup

private extension ProfileTaskScreen {
    
    func setupContentView() {
        contentContainer.view.backgroundColor = .black
        
        contentContainer.scrollView.clipsToBounds = false
        
        contentContainer.setTopSpacing(52)
        contentContainer.appendChild(screenView.profileView)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.reportTitleView)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.reportView)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.answerButton)
        contentContainer.appendChild(screenView.scoreLabel)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.crimeDescriptionLabel)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.answersView)
        contentContainer.setBottomSpacing(20)
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer.delegate = self
        contentContainer.scrollView.addGestureRecognizer(backgroundTapRecognizer)
        
        let backgroundTapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer1.delegate = self
        contentContainer.stackView.addGestureRecognizer(backgroundTapRecognizer1)
        
        let backgroundTapRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer2.delegate = self
        screenView.profileView.listView.addGestureRecognizer(backgroundTapRecognizer2)
    }
    
    func setupViews() {
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        if !User.shared.isProfileHelpShown {
            view.addSubview(helpButton)
            
            helpButton.addTarget(self, action: #selector(didTapHelpButton), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                helpButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
                helpButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            ])
        }
        
        screenView.setupViews()
    }
    
    func setupScreenLoadingView() {
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
    }
    
    func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                if let offset = self.calculateTargetScrollViewYOffset(keyboardFrame: frame) {
                    self.contentScrollViewOffset = offset
                    self.contentContainer.scrollView.contentOffset.y += offset
                } else {
                    self.contentScrollViewOffset = nil
                }
                self.contentContainer.scrollView.contentInset.bottom = frame.height
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                if let contentScrollViewOffset = self.contentScrollViewOffset {
                    self.contentContainer.scrollView.contentOffset.y -= contentScrollViewOffset
                    self.contentScrollViewOffset = nil
                }
                self.contentContainer.scrollView.contentInset.bottom = 0
            }
        }
    }
    
    // MARK: - Utils
    
    func calculateTargetScrollViewYOffset(keyboardFrame: CGRect) -> CGFloat? {
        guard var focusedView = contentContainer.stackView.currentFirstResponder() as? UIView else { return nil }
        
        focusedView = focusedView.superview?.superview ?? focusedView
        
        let convertedFocusedViewFrame = focusedView.convert(focusedView.bounds, to: view)
        
        let visibleContentHeight = view.bounds.height - keyboardFrame.height
        
        let focusedViewMaxY = convertedFocusedViewFrame.maxY
        
        if visibleContentHeight > focusedViewMaxY {
            return nil
        } else {
            return max(0, focusedViewMaxY - visibleContentHeight)
        }
    }
    
}

extension ProfileTaskScreen: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view === gestureRecognizer.view
    }
    
}

