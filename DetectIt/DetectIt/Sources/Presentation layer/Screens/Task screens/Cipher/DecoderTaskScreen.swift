import SwiftUI
import DetectItUI
import DetectItCore

struct DecoderTaskScreenSUI: UIViewControllerRepresentable {
    let task: DecoderTask
    let isTaskCompleted: Bool
    let onClose: (_ isCompleted: Bool, _ score: Int) -> Void
    
    init(
        task: DecoderTask,
        isTaskCompleted: Bool,
        onClose: @escaping (_ isCompleted: Bool, _ score: Int) -> Void
    ) {
        self.task = task
        self.isTaskCompleted = isTaskCompleted
        self.onClose = onClose
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let screen = DecoderTaskScreen(task: task, isTaskCompleted: isTaskCompleted, onClose: onClose)
        let nav = UINavigationController(rootViewController: screen)
        nav.isNavigationBarHidden = true
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

final class DecoderTaskScreen: Screen {
    
    // MARK: - Subviews
    
    let screenLoadingView = ScreenLoadingView(isInitiallyHidden: true)
    
    let contentContainer = StackViewController()
    
    let topPanel = TaskScreenTopPanel()
    let screenView = DecoderTaskScreenView()
    lazy var taskSharingViewController = TaskSharingViewController(task: task)
    
    let keyboardManager = KeyboardManager()
    var contentScrollViewOffset: CGFloat?
        
    // MARK: - State
    
    let task: DecoderTask
    let isTaskCompleted: Bool
    let onClose: (_ isCompleted: Bool, _ score: Int) -> Void
    
    var encodedImage: UIImage?
    var encodedAudio: Data?
    
    var score: Int?
    var answer: String?
            
    // MARK: - Init
    
    init(
        task: DecoderTask,
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
        
        view.backgroundColor = .darkBackground
        
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
        
        if !HelpScreen.isShown(taskKind: task.kind) {
            let s = HelpScreen(taskKind: task.kind)
            s.modalPresentationStyle = .pageSheet
            s.modalTransitionStyle = .coverVertical
            present(s, animated: true)
        }
        
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
