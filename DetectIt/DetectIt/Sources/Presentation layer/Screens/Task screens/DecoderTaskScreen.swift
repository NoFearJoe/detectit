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

final class DecoderTaskScreen: Screen {
    
    // MARK: - Subviews
    
    private let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    private let contentContainer = StackViewController()
    
    private let closeButton = SolidButton.closeButton()
    private let helpButton = SolidButton.helpButton()
    
    private let screenView = DecoderTaskScreenView()
    
    private let keyboardManager = KeyboardManager()
    private var contentScrollViewOffset: CGFloat?
    
    // MARK: - State
    
    private let task: DecoderTask
    private let bundle: TasksBundle.Info?
    
    private var encodedImage: UIImage?
    
    private var score: Int?
        
    // MARK: - Init
    
    init(task: DecoderTask, bundle: TasksBundle.Info?) {
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
        
        score = TaskScore.get(id: task.id, taskKind: .cipher, bundleID: bundle?.id)
        
        updateContentState(animated: false)
        
        loadTask()
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapHelpButton() {
        User.shared.isDecoderHelpShown = true
        
        helpButton.isHidden = true
        
        present(HelpScreen(taskKind: task.kind), animated: true, completion: nil)
    }
    
    private func didTapEncodedPicture() {
        guard let image = encodedImage else { return }
        
        let imageViewer = PhotoViewerScreen(image: image, title: nil)
        
        present(imageViewer, animated: true, completion: nil)
    }
    
    private func didTapAnswerButton() {
        view.endEditing(true)
        
        commitAnswer()
        
        updateContentState(animated: true)
        
        scrollToResults()
    }
    
    @objc private func onTapBackground() {
        view.endEditing(true)
    }
    
    // MARK: - Business logic
    
    private func loadTask() {
        screenLoadingView.setVisible(true, animated: false)
        screenPlaceholderView.setVisible(false, animated: false)
        
        loadData { [weak self] image in
            self?.encodedImage = image
                        
            guard let image = image else {
                self?.screenPlaceholderView.setVisible(true, animated: false)
                self?.screenLoadingView.setVisible(false, animated: true)
                self?.screenPlaceholderView.configure(
                    title: "network_error_title".localized,
                    message: "network_error_message".localized,
                    onRetry: { [unowned self] in self?.loadTask() }
                )
                return
            }
            
            self?.screenLoadingView.setVisible(false, animated: true)
            self?.displayContent(encodedPicture: image)
        }
    }
    
    private func loadData(completion: @escaping (UIImage?) -> Void) {
        ImageLoader.share.load(
            .staticAPI(task.encodedPictureName)
        ) { image in
            completion(image)
        }
    }
    
    private func commitAnswer() {
        let answer = screenView.questionAndAnswerView.answer
        
        let isCorrectAnswer = task.answer.compare(with: answer)
        let score = isCorrectAnswer ? task.maxScore : 0
        
        TaskScore.set(value: score, id: task.id, taskKind: task.kind, bundleID: bundle?.id)
        TaskAnswer.set(answer: answer, decoderTaskID: task.id, bundleID: bundle?.id)
        
        self.score = score
    }
    
    // MARK: - Utils
    
    private func displayContent(encodedPicture: UIImage) {
        screenView.titleLabel.text = task.title
        screenView.prepositionLabel.attributedText = task.preposition.readableAttributedText()
        screenView.encodedPictureView.image = encodedPicture
        screenView.questionAndAnswerView.configure(
            model: QuestionAndAnswerView.Model(
                question: "decoder_task_screen_answer_title".localized,
                answer: TaskAnswer.get(decoderTaskID: task.id, bundleID: bundle?.id)
            )
        )
        screenView.crimeDescriptionLabel.attributedText = task.answer.crimeDescription.readableAttributedText()
        screenView.rightAnswerView.answer = task.answer.decodedMessage
    }
    
    private func updateContentState(animated: Bool) {
        // Если есть счет, значит задание решено
        let isSolved = score != nil
        let isSolvedCorrectly = score == task.maxScore
        
        contentContainer.setChildHidden(screenView.answerButton, hidden: isSolved, animated: false)
        contentContainer.setChildHidden(screenView.scoreLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.crimeDescriptionLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(screenView.rightAnswerView, hidden: !isSolved || isSolvedCorrectly, animated: animated, animationDuration: 2)
        
        screenView.scoreLabel.text = score.map { "\($0)/\(task.maxScore)" }
        screenView.scoreLabel.textColor = .score(value: score, max: task.maxScore, defaultColor: .white)
        
        screenView.questionAndAnswerView.isUserInteractionEnabled = !isSolved
        
        guard isSolved else { return }
        
        screenView.questionAndAnswerView.highlight(isCorrect: isSolvedCorrectly, animated: animated, animationDuration: 2)
    }
    
    func scrollToResults() {
        view.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let minY = self.screenView.scoreLabel.frame.minY
            let maxY = self.screenView.crimeDescriptionLabel.frame.maxY
            let targetY = maxY - minY > self.view.bounds.height ? minY : max(0, maxY - self.view.bounds.height)
            
            UIView.animate(withDuration: 0.5, animations: {
                self.contentContainer.scrollView.contentOffset = CGPoint(x: 0, y: targetY)
            }) { _ in
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupContentView() {
        contentContainer.view.backgroundColor = .black
                
        contentContainer.scrollView.clipsToBounds = false
        
        contentContainer.setTopSpacing(52)
        contentContainer.appendChild(screenView.titleLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.prepositionLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.encodedPictureContainer)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.questionAndAnswerView)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.answerButton)
        contentContainer.appendChild(screenView.scoreLabel)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.rightAnswerView)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.crimeDescriptionLabel)
        contentContainer.setBottomSpacing(20)
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer.delegate = self
        contentContainer.scrollView.addGestureRecognizer(backgroundTapRecognizer)
        
        let backgroundTapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer1.delegate = self
        contentContainer.stackView.addGestureRecognizer(backgroundTapRecognizer1)
    }
    
    private func setupViews() {
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        if !User.shared.isDecoderHelpShown {
            view.addSubview(helpButton)
            
            helpButton.addTarget(self, action: #selector(didTapHelpButton), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                helpButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
                helpButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            ])
        }
        
        screenView.setupViews()
        
        screenView.onTapEncodedPicture = didTapEncodedPicture
        screenView.onTapAnswerButton = didTapAnswerButton
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
        
        focusedView = screenView.questionAndAnswerView
        
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

extension DecoderTaskScreen: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view === gestureRecognizer.view
    }
    
}
