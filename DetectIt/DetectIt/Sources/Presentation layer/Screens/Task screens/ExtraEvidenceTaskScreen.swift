//
//  ExtraEvidenceTaskScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class ExtraEvidenceTaskScreen: Screen {
    
    private let placeholderView = ScreenPlaceholderView(isInitiallyHidden: true)
    
    private let contentContainer = StackViewController()
    
    private let closeButton = SolidButton.closeButton()
    
    public let titleLabel = UILabel()

    private lazy var evidenceListView = EvidenceListView(delegate: self)
            
    public let answerButton = AnswerButton()
    
    public let scoreLabel = UILabel()
    public let rightAnswerView = DecoderTaskRightAnswerView()
    public let crimeDescriptionLabel = UILabel()
    
    // MARK: - Init
    
    private let task: ExtraEvidenceTask
    private let bundle: TasksBundle
    
    private var evidenceImages: [String: UIImage] = [:]
    
    private var selectedEvidenceIndex: Int? {
        didSet {
            answerButton.isEnabled = selectedEvidenceIndex != nil
        }
    }
    
    private var score: Int?
    
    init(task: ExtraEvidenceTask, bundle: TasksBundle) {
        self.task = task
        self.bundle = bundle
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Overrides
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func loadView() {
        super.loadView()
        
        contentContainer.place(into: self)
        
        setupPlaceholderView()
        setupViews()
        setupContentView()
        
        isStatusBarBlurred = true
    }
    
    override func prepare() {
        super.prepare()
        
        placeholderView.setVisible(true, animated: false)
        
        score = TaskScore.get(id: task.id, taskKind: task.kind, bundleID: bundle.info.id)
        
        if let answer = TaskAnswer.get(extraEvidenceTaskID: task.id) {
            selectedEvidenceIndex = task.evidencePictures.firstIndex(where: { $0.pictureName == answer })
        }
        
        updateContentState(animated: false)
        
        loadData { [weak self] success in
            self?.placeholderView.setVisible(false, animated: true)
            
            guard success else {
                // TODO: Show error placeholder
                return
            }
            
            self?.displayContent()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func didTapAnswerButton() {
        view.endEditing(true)
        
        commitAnswer()
        
        updateContentState(animated: true)
        
        scrollToResults()
    }
    
    // MARK: - Business logic
    
    private func loadData(completion: @escaping (Bool) -> Void) {
        guard !task.evidencePictures.isEmpty else {
            return completion(false)
        }
        
        let dispatchGroup = DispatchGroup()
        
        task.evidencePictures.forEach { picture in
            guard let url = task.evidencePictureURL(picture: picture, bundleID: bundle.info.id) else { return }
            
            dispatchGroup.enter()
            
            ImageLoader.share.load(.file(url), postprocessing: { $0.applyingOldPhotoFilter() }) { [weak self] image in
                self?.evidenceImages[picture.pictureName] = image
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(true)
        }
    }
    
    private func commitAnswer() {
        guard let answer = selectedEvidenceIndex else { return }
        let selectedEvidence = task.evidencePictures[answer]
        guard let correctEvidence = task.evidencePictures.first(where: { $0.pictureName == task.answer.evidencePictureName }) else { return }

        let isCorrectAnswer = selectedEvidence.pictureName == correctEvidence.pictureName
        let score = isCorrectAnswer ? task.maxScore : 0

        TaskScore.set(value: score, id: task.id, taskKind: task.kind, bundleID: bundle.info.id)
        TaskAnswer.set(answer: selectedEvidence.pictureName, extraEvidenceTaskID: task.id)

        self.score = score
    }
    
    // MARK: - Utils
    
    private func displayContent() {
        titleLabel.text = task.title
        crimeDescriptionLabel.attributedText = task.answer.crimeDescription.readableAttributedText()
        rightAnswerView.answer = task.answer.evidencePictureName // TODO
        evidenceListView.reloadData()
    }
    
    private func updateContentState(animated: Bool) {
        // Если есть счет, значит задание решено
        let isSolved = score != nil
        let isSolvedCorrectly = score == task.maxScore
        
        contentContainer.setChildHidden(answerButton, hidden: isSolved, animated: false)
        contentContainer.setChildHidden(scoreLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(crimeDescriptionLabel, hidden: !isSolved, animated: animated, animationDuration: 2)
        contentContainer.setChildHidden(rightAnswerView, hidden: !isSolved || isSolvedCorrectly, animated: animated, animationDuration: 2)
        
        scoreLabel.text = score.map { "\($0)/\(task.maxScore)" }
        scoreLabel.textColor = .score(value: score, max: task.maxScore, defaultColor: .white)
        
        evidenceListView.isUserInteractionEnabled = !isSolved
    }
    
    func scrollToResults() {
        view.isUserInteractionEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let minY = self.scoreLabel.frame.minY
            let maxY = self.crimeDescriptionLabel.frame.maxY
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
        
        contentContainer.stackView.layoutMargins = UIEdgeInsets(
            top: 0, left: 20, bottom: 0, right: 20
        )
        
        contentContainer.setTopSpacing(20)
        contentContainer.appendChild(titleLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(evidenceListView)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(answerButton)
        contentContainer.appendChild(scoreLabel)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(rightAnswerView)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(crimeDescriptionLabel)
        contentContainer.setBottomSpacing(20)
    }
    
    private func setupViews() {
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        answerButton.isEnabled = false
//        answerButton.setTitle("Отправить ответ", for: .normal) // TODO
        answerButton.onFill = { [unowned self] in
            self.didTapAnswerButton()
        }
        
        scoreLabel.font = .score1
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        
        crimeDescriptionLabel.font = .text3
        crimeDescriptionLabel.textColor = .white
        crimeDescriptionLabel.numberOfLines = 0
    }
    
    func setupPlaceholderView() {
        view.addSubview(placeholderView)
        placeholderView.pin(to: view)
    }
    
}

extension ExtraEvidenceTaskScreen: EvidenceListViewDelegate {
    
    func numberOfEvidences() -> Int {
        task.evidencePictures.count
    }
    
    func evidenceModel(at index: Int) -> EvidenceCell.Model? {
        let evidence = task.evidencePictures[index]
        guard let image = evidenceImages[evidence.pictureName] else { return nil }
        
        return .init(photo: image, title: evidence.title, isSelected: selectedEvidenceIndex == index)
    }
    
    func didSelectEvidence(at index: Int) {
        selectedEvidenceIndex = index
        
        evidenceListView.reloadData()
        
        TaskAnswer.set(answer: task.evidencePictures[index].pictureName, extraEvidenceTaskID: task.id)
    }
    
    func didLongTapEvidence(at index: Int) {
        let evidence = task.evidencePictures[index]
        guard let image = evidenceImages[evidence.pictureName] else { return }
        
        let imageViewer = PhotoViewerScreen(image: image, title: nil)

        present(imageViewer, animated: true, completion: nil)
    }
    
}
