import SwiftUI
import DetectItUI
import DetectItCore

struct ProfileTaskScreenSUI: UIViewControllerRepresentable {
    let task: ProfileTask
    let isTaskCompleted: Bool
    let onClose: (_ isCompleted: Bool, _ score: Int) -> Void
    
    init(
        task: ProfileTask,
        isTaskCompleted: Bool,
        onClose: @escaping (_ isCompleted: Bool, _ score: Int) -> Void
    ) {
        self.task = task
        self.isTaskCompleted = isTaskCompleted
        self.onClose = onClose
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let screen = ProfileTaskScreen(task: task, isTaskCompleted: isTaskCompleted, onClose: onClose)
        let nav = UINavigationController(rootViewController: screen)
        nav.isNavigationBarHidden = true
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

final class ProfileTaskScreen: Screen {
    
    // MARK: - Subviews
    
    let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    let contentContainer = StackViewController()
    
    let topPanel = TaskScreenTopPanel()
    lazy var screenView = ProfileTaskScreenView(delegate: self)
    lazy var taskSharingViewController = TaskSharingViewController(task: task)
    
    let keyboardManager = KeyboardManager()
    var contentScrollViewOffset: CGFloat?
        
    // MARK: - State
    
    let task: ProfileTask
    let isTaskCompleted: Bool
    let onClose: (_ isCompleted: Bool, _ score: Int) -> Void
    
    var isDataLoaded = false
    
    var images: [String: UIImage] = [:]
    var audios: [String: Data] = [:]
    
    var answers = Answers() {
        didSet {
            TaskAnswer.set(answers: answers.answers, profileTaskID: task.id)
            
            updateAnswerButtonState()
        }
    }
    
    var score: Int?
    
    var isSolved: Bool {
        score != nil
    }
    
    // MARK: - Init
    
    init(
        task: ProfileTask,
        isTaskCompleted: Bool,
        onClose: @escaping (_ isCompleted: Bool, _ score: Int) -> Void
    ) {
        self.task = task
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
            },
            onReport: nil
        )
        
        loadTask()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !HelpScreen.isShown(taskKind: task.kind) {
            let s = HelpScreen(taskKind: task.kind)
            s.modalPresentationStyle = .pageSheet
            s.modalTransitionStyle = .coverVertical
            present(s, animated: true)
        }
        
        Analytics.logScreenShow(
            .profileTask,
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
    
    func numberOfAttachments(in view: AttachmentsView) -> Int {
        isDataLoaded ? (task.attachments?.count ?? 0) : 0
    }
    
    func attachment(at index: Int, in view: AttachmentsView) -> Any? {
        guard let attachment = task.attachments?[index] else {
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
        let controller = UIHostingController(rootView: screen)
        controller.presentationController?.delegate = self
        
        present(controller, animated: true, completion: nil)
        
        Analytics.logButtonTap(title: "profile_task_screen_get_status_button_title".localized, screen: .profileTask)
    }
    
}

extension ProfileTaskScreen: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TaskScreenOpenTransitionAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        TaskScreenCloseTransitionAnimator()
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
        static let bottomInset = CGFloat(28)
    }
}
