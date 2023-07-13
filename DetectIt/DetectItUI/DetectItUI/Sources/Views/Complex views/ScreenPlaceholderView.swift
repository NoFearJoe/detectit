import SwiftUI

public struct ScreenPlaceholderViewSUI: View {
    let title: String
    let message: String?
    
    public init(title: String, message: String?) {
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text(title)
                .font(.heading4)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            if let message {
                Spacer().frame(height: 12)
                
                Text(message)
                    .font(.text3)
                    .foregroundColor(.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding()
    }
}

public final class ScreenPlaceholderView: UIView {
    
    var onRetry: (() -> Void)?
    var onReport: (() -> Void)?
    var onClose: (() -> Void)?
    
    private let closeButton = SolidButton.closeButton()
    private let contentView = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let retryButton = UIButton()
    private let reportButton = UIButton()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public func configure(
        title: String,
        message: String?,
        onRetry: (() -> Void)?,
        onClose: (() -> Void)?,
        onReport: (() -> Void)?
    ) {
        self.onRetry = onRetry
        self.onClose = onClose
        self.onReport = onReport
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.isHidden = message == nil
        retryButton.isHidden = onRetry == nil
        reportButton.isHidden = onReport == nil
        
        closeButton.isHidden = onClose == nil
    }
    
    public func setVisible(_ isVisible: Bool, animated: Bool) {
        superview?.bringSubviewToFront(self)
        
        alpha = isVisible ? 0 : 1
        
        UIView.animate(
            withDuration: animated ? 0.5 : 0,
            animations: {
                self.alpha = isVisible ? 1 : 0
            },
            completion: nil
        )
    }
    
    private func setup() {
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupViews() {
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20)
        ])
        
        contentView.axis = .vertical
        contentView.distribution = .fill
        contentView.alignment = .center
        
        contentView.addArrangedSubview(titleLabel)
        contentView.addArrangedSubview(messageLabel)
        contentView.addArrangedSubview(retryButton)
        
        contentView.setCustomSpacing(12, after: titleLabel)
        contentView.setCustomSpacing(40, after: messageLabel)
        
        titleLabel.font = .heading4
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        messageLabel.font = .text3
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        retryButton.titleLabel?.font = .text2
        retryButton.setTitleColor(.yellow, for: .normal)
        retryButton.setTitleColor(UIColor.yellow.withAlphaComponent(0.75), for: .highlighted)
        retryButton.setTitle("retry_button_title".localized, for: .normal)
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        retryButton.addTarget(self, action: #selector(didTapRetryButton), for: .touchUpInside)
        
        addSubview(reportButton)
        
        reportButton.titleLabel?.font = .text3
        reportButton.setTitleColor(.lightGray, for: .normal)
        reportButton.setTitleColor(UIColor.lightGray.withAlphaComponent(0.75), for: .highlighted)
        reportButton.setTitle("report_button_title".localized, for: .normal)
        reportButton.contentEdgeInsets = UIEdgeInsets(top: 28, left: 16, bottom: 8, right: 16)
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            reportButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            reportButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func didTapRetryButton() {
        onRetry?()
    }
    
    @objc private func didTapReportButton() {
        onReport?()
    }
    
    @objc private func didTapCloseButton() {
        onClose?()
    }
    
}
