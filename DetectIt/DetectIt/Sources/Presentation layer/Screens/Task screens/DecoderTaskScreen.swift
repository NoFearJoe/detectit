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
    
    private let placeholderView = ScreenPlaceholderView(isInitiallyHidden: true)
    
    private let contentContainer = StackViewController()
    
    private let closeButton = SolidButton.closeButton()
    
    private let screenView = DecoderTaskScreenView()
    
    private let keyboardManager = KeyboardManager()
    private var contentScrollViewOffset: CGFloat?
    
    // MARK: - State
    
    private let task: DecoderTask
    private let bundle: TasksBundle
    
    private var encodedImage: UIImage?
    
    private var score: Int?
        
    // MARK: - Init
    
    init(task: DecoderTask, bundle: TasksBundle) {
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
        
        contentContainer.place(into: self)
        
        setupPlaceholderView()
        setupViews()
        setupContentView()
        setupKeyboardManager()
        
        isStatusBarBlurred = true
    }
    
    override func prepare() {
        super.prepare()
        
        placeholderView.setVisible(true, animated: false)
        
        score = TaskScore.get(id: task.id, taskKind: .cipher, bundleID: bundle.info.id)
        
        #warning("Remove")
        displayContent(encodedPicture: UIImage())
        
        updateContentState(animated: false)
        
        loadData { [weak self] image in
            self?.encodedImage = image
            
            self?.placeholderView.setVisible(false, animated: true)
            
            guard let image = image else {
                // TODO: Show error placeholder
                return
            }
            
            self?.displayContent(encodedPicture: image)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
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
    }
    
    @objc private func onTapBackground() {
        view.endEditing(true)
    }
    
    // MARK: - Business logic
    
    private func loadData(completion: @escaping (UIImage?) -> Void) {
        guard let imageURL = task.encodedPictureURL(bundleID: bundle.info.id) else {
            return completion(nil)
        }
        
        ImageLoader.share.load(
            .file(imageURL)
        ) { image in
            completion(image)
        }
    }
    
    private func commitAnswer() {
        let answer = screenView.questionAndAnswerView.answer
        
        let isCorrectAnswer = task.answer.compare(with: answer)
        let score = isCorrectAnswer ? task.maxScore : 0
        
        TaskScore.set(value: score, id: task.id, taskKind: task.kind, bundleID: bundle.info.id)
        TaskAnswer.set(answer: answer, decoderTaskID: task.id)
        
        self.score = score
    }
    
    // MARK: - Utils
    
    private func displayContent(encodedPicture: UIImage) {
        screenView.titleLabel.text = task.title
        screenView.prepositionLabel.attributedText = task.preposition.readableAttributedText()
        screenView.encodedPictureView.image = encodedPicture
        screenView.questionAndAnswerView.configure(
            model: QuestionAndAnswerView.Model(question: "Ответ:") // TODO
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
    
    // MARK: - Setup
    
    private func setupContentView() {
        contentContainer.view.backgroundColor = .black
        
        contentContainer.stackView.layoutMargins = UIEdgeInsets(
            top: 0, left: 20, bottom: 0, right: 20
        )
        
        contentContainer.setTopSpacing(20)
        contentContainer.appendChild(screenView.titleLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.prepositionLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.encodedPictureView)
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
        
        screenView.setupViews()
        
        screenView.onTapEncodedPicture = didTapEncodedPicture
        screenView.onTapAnswerButton = didTapAnswerButton
    }
    
    func setupPlaceholderView() {
        view.addSubview(placeholderView)
        placeholderView.pin(to: view)
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
