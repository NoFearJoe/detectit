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
    
    private let titleLabel = UILabel()
    private let prepositionLabel = UILabel()
    private let encodedPictureView = UIImageView()
    private let questionAndAnswerView = QuestionAndAnswerView()
    private let answerButton = SolidButton.primaryButton()
    
    private let keyboardManager = KeyboardManager()
    private var contentScrollViewOffset: CGFloat?
    
    // MARK: - State
    
    private let task: DecoderTask
    private let bundle: TasksBundle
        
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
        
        setupViews()
        setupContentView()
        setupKeyboardManager()
        
        isStatusBarBlurred = true
    }
    
    override func prepare() {
        super.prepare()
        
        placeholderView.setVisible(true, animated: false)
        
        loadData { [weak self] image in
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
    
    @objc private func didTapEncodedPicture() {
        // TODO: Show image viewer
    }
    
    @objc private func didTapAnswerButton() {
        view.endEditing(true)
        
        let answer = questionAndAnswerView.answer
        let rightAnswer = task.answer.decodedMessage
        
        let isCorrectAnswer = answer == rightAnswer
        let score = isCorrectAnswer ? task.maxScore : 0
        
        TaskScore.set(score: score, decoderTaskID: task.id)
        TaskAnswer.set(answer: answer, decoderTaskID: task.id)
        
        // TODO: Show alert
    }
    
    @objc private func onTapBackground() {
        view.endEditing(true)
    }
    
    // MARK: - Utils
    
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
    
    private func displayContent(encodedPicture: UIImage) {
        titleLabel.text = task.title
        prepositionLabel.text = task.preposition
        encodedPictureView.image = encodedPicture
        questionAndAnswerView.configure(
            model: QuestionAndAnswerView.Model(question: "Ответ:") // TODO
        )
    }
    
    // MARK: - Setup
    
    private func setupContentView() {
        contentContainer.view.backgroundColor = .black
        
        contentContainer.stackView.layoutMargins = UIEdgeInsets(
            top: 0, left: 20, bottom: 0, right: 20
        )
        
        contentContainer.setTopSpacing(20)
        contentContainer.appendChild(titleLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(prepositionLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(encodedPictureView)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(questionAndAnswerView)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(answerButton)
        contentContainer.setBottomSpacing(20)
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer.delegate = self
        contentContainer.scrollView.addGestureRecognizer(backgroundTapRecognizer)
        
        let backgroundTapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer1.delegate = self
        contentContainer.stackView.addGestureRecognizer(backgroundTapRecognizer1)
    }
    
    private func setupViews() {
        setupPlaceholderView()
        
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        titleLabel.font = .bold(28)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        prepositionLabel.font = .regular(15)
        prepositionLabel.textColor = .white
        prepositionLabel.numberOfLines = 0
        
        encodedPictureView.layer.allowsEdgeAntialiasing = true
        encodedPictureView.transform = CGAffineTransform
            .randomLayout()
            .concatenating(CGAffineTransform(scaleX: 0.9, y: 0.9))
        
        encodedPictureView.configureShadow(radius: 20, opacity: 0.2, color: .white, offset: .zero)
        
        encodedPictureView.isUserInteractionEnabled = true
        encodedPictureView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapEncodedPicture))
        )
        
        questionAndAnswerView.onChangeAnswer = { [unowned self] answer in
            self.answerButton.isEnabled = !answer.isEmpty
        }
        
        answerButton.isEnabled = false
        answerButton.setTitle("Отправить ответ", for: .normal) // TODO
        answerButton.addTarget(self, action: #selector(didTapAnswerButton), for: .touchUpInside)
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
        
        focusedView = questionAndAnswerView
        
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
