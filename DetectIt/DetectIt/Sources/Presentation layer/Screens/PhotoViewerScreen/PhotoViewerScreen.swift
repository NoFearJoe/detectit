import SwiftUI
import DetectItUI

final class PhotoViewerScreen: Screen {
    
    // MARK: - Subviews
    
    private let closeButton = SolidButton.closeButton()
    private let backgroundBlurView = BlurView(style: .systemChromeMaterialDark)
    private let titleLabel = UILabel()
    
    private let scrollView = UIScrollView()
    private let imageContainer = UIView()
    private let imageView = AutosizingImageView()
    
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let swipeToDismissRecognizer = UIPanGestureRecognizer()
    
    private var swipeToDismissTransition: SwipeToDismissTransition?
    
    private var itemsCount = 1
    
    private let thresholdVelocity = CGFloat(500)
    
    init(image: UIImage, title: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        imageView.image = image
        titleLabel.text = title
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepare() {
        setup()
        setupViews()
        setupGestureRecognizers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.invalidateIntrinsicContentSize()
        imageContainer.layoutIfNeeded()
    }
    
    // MARK: - Actions
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didDoubleTap() {
        if scrollView.zoomScale == 1.0 || scrollView.zoomScale > 2 {
            self.scrollView.setZoomScale(2, animated: true)
        } else {
            self.scrollView.setZoomScale(1, animated: true)
        }
    }
    
    @objc private func didSwipeToDismiss() {
        guard scrollView.zoomScale == scrollView.minimumZoomScale else { return }

        let currentVelocity = swipeToDismissRecognizer.velocity(in: view)
        let currentTouchPoint = swipeToDismissRecognizer.translation(in: view)

        switch swipeToDismissRecognizer.state {
        case .began:
            swipeToDismissTransition = SwipeToDismissTransition(dragView: imageView, dimmingView: backgroundBlurView)
        case .changed:
            handleSwipeToDismissInProgress(forTouchPoint: currentTouchPoint)
        case .ended:
            handleSwipeToDismissEnded(finalVelocity: currentVelocity, finalTouchPoint: currentTouchPoint)
        default:
            break
        }
    }
    
    // MARK: - Setup
    
    private func setup() {
        view.backgroundColor = .clear
    }
    
    private func setupViews() {
        view.addSubview(backgroundBlurView)
        backgroundBlurView.blurRadius = 20
        backgroundBlurView.colorTint = UIColor.systemBackground.withAlphaComponent(0.5)
//        backgroundBlurView.colorTintAlpha = 0.5
        backgroundBlurView.pin(to: view)
        
        setupScrollView()
        
        scrollView.addSubview(imageContainer)
        
        imageContainer.backgroundColor = .clear
        
        imageContainer.pin(to: scrollView)
        NSLayoutConstraint.activate([
            imageContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        imageContainer.addSubview(imageView)
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: imageContainer.leadingAnchor)
        ])
        
        view.addSubview(titleLabel)
        
        titleLabel.font = .text4
        titleLabel.textColor = .lightGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: backgroundBlurView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundBlurView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundBlurView.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
        
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint.zero
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5

        scrollView.delegate = self
        
        scrollView.pin(to: view)
    }
    
    private func setupGestureRecognizers() {
        doubleTapRecognizer.addTarget(self, action: #selector(didDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)

        swipeToDismissRecognizer.delegate = self
        swipeToDismissRecognizer.addTarget(self, action: #selector(didSwipeToDismiss))
        imageView.addGestureRecognizer(swipeToDismissRecognizer)
        swipeToDismissRecognizer.require(toFail: doubleTapRecognizer)
    }
    
}

extension PhotoViewerScreen: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageContainer
    }
    
}

extension PhotoViewerScreen: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === swipeToDismissRecognizer else { return true }
        
        return scrollView.zoomScale == scrollView.minimumZoomScale
    }
    
}

private extension PhotoViewerScreen {
    
    func handleSwipeToDismissInProgress(forTouchPoint touchPoint: CGPoint) {
        swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: touchPoint.x, verticalOffset: touchPoint.y)
    }

    func handleSwipeToDismissEnded(finalVelocity velocity: CGPoint, finalTouchPoint touchPoint: CGPoint) {
        let swipeToDismissCompletionBlock: (() -> Void)? = { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }
        
        let shouldFinish = max(abs(velocity.x), abs(velocity.y)) > thresholdVelocity && touchPoint != .zero
        
        let angle = CGPoint.angle(start: .zero, end: velocity).radians
        
        let distance = sqrt(pow(imageContainer.bounds.width / 2, 2) + pow(imageContainer.bounds.height / 2, 2))
        let targetOffset = CGPoint(
            x: (distance + imageView.bounds.width) * cos(angle),
            y: (distance + imageView.bounds.height) * sin(angle)
        )
        
        if shouldFinish {
            view.isUserInteractionEnabled = false
            
            swipeToDismissTransition?.finishInteractiveTransition(
                touchPoint: touchPoint,
                targetOffset: targetOffset,
                escapeVelocity: velocity,
                completion: swipeToDismissCompletionBlock
            )
        } else {
            swipeToDismissTransition?.cancelTransition()
        }
    }
    
}

final class SwipeToDismissTransition {

    private unowned let dragView: UIView
    private unowned let dimmingView: UIView

    init(dragView: UIView, dimmingView: UIView) {
        self.dragView = dragView
        self.dimmingView = dimmingView
    }

    func updateInteractiveTransition(horizontalOffset hOffset: CGFloat = 0, verticalOffset vOffset: CGFloat = 0) {
        dragView.transform = CGAffineTransform(translationX: hOffset, y: vOffset)
        
        let maxOffset = max(abs(hOffset), abs(vOffset))
        let backgroundAlpha = max(0, 1 - (maxOffset / (dimmingView.bounds.height * 0.5)))
        
        dimmingView.alpha = backgroundAlpha
    }

    func finishInteractiveTransition(touchPoint: CGPoint,
                                     targetOffset: CGPoint,
                                     escapeVelocity: CGPoint,
                                     completion: (() -> Void)?) {
        let diff = targetOffset - touchPoint
        let maxOffset = max(abs(diff.x), abs(diff.y))
        let maxVelocity = max(abs(escapeVelocity.x), abs(escapeVelocity.y))
        
        let springVelocity = abs(maxVelocity / maxOffset)
        let expectedDuration = TimeInterval(maxOffset / maxVelocity)

        UIView.animate(
            withDuration: expectedDuration * 0.5,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: springVelocity,
            options: .curveLinear,
            animations: {
                self.dragView.transform = CGAffineTransform(translationX: targetOffset.x, y: targetOffset.y)
                self.dimmingView.alpha = 0
            }, completion: { _ in
                completion?()
            }
        )
    }

    func cancelTransition(_ completion: (() -> Void)? = {}) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveLinear,
            animations: {
                self.dragView.transform = .identity
                self.dimmingView.alpha = 1
            }
        ) { _ in
            completion?()
        }
    }
}
