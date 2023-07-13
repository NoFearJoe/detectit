import UIKit

public final class ScreenHeaderView: UIView {
    
    public var onClose: (() -> Void)?
    
    private var gradientView = GradientView()
    
    public let closeButton = SolidButton.closeButton()
    public let titleLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTapCloseButton() {
        onClose?()
    }
    
    private func setupViews() {
        addSubview(gradientView)
        gradientView.startColor = .black
        gradientView.endColor = .black.withAlphaComponent(0)
        gradientView.pin(to: self, insets: UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0))
        
        addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -.hInset)
        ])
        
        addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        titleLabel.font = .heading3
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .hInset),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: closeButton.topAnchor)
        ])
    }
    
}

