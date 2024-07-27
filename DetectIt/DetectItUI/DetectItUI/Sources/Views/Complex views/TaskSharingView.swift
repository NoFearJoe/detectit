import SwiftUI
import DetectItCore

public struct TaskSharingViewSUI: View {
    let task: Task
    let onShare: () -> Void
    
    @State private var isSharingPresented = false
    
    public init(task: Task, onShare: @escaping () -> Void) {
        self.task = task
        self.onShare = onShare
    }
    
    public var body: some View {
        HStack {
            Text("task_sharing_title".localized)
                .font(.text3)
                .foregroundStyle(.white)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Image("share", bundle: .ui)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.yellow)
        }
        .padding(.horizontal, .hInset)
        .padding(.vertical, 16)
        .background(Color.darkBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture {
            onShare()
            isSharingPresented = true
        }
        .overlay {
            if isSharingPresented {
                ActivityPopover(items: [Self.makeSharingContent(task: task)]) { _, _, _, _ in
                    isSharingPresented = false
                }
            }
        }
    }
    
    public static func makeSharingContent(task: Task) -> String {
        let taskLink = AppRateManager.appStoreLink.absoluteString
        
        switch task.kind {
        case .cipher:
            return String(format: "task_sharing_text_for_cipher".localized, task.title, taskLink)
        case .profile:
            return String(format: "task_sharing_text_for_profile".localized, task.title, taskLink)
        case .blitz:
            return String(format: "task_sharing_text_for_blitz".localized, task.title, taskLink)
        case .quest:
            return String(format: "task_sharing_text_for_quest".localized, task.title, taskLink)
        }
    }
}

public final class TaskSharingView: UIView, TouchAnimatable {
    
    public var onShare: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let shareIcon = UIImageView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTap() {
        onShare?()
    }
    
    private func setup() {
        enableTouchAnimation()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
        
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        backgroundColor = .darkBackground
        
        layoutMargins = UIEdgeInsets(top: 16, left: .hInset, bottom: 16, right: .hInset)
        
        addSubview(titleLabel)
        titleLabel.text = "task_sharing_title".localized
        titleLabel.textColor = .white
        titleLabel.font = .text3
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(shareIcon)
        shareIcon.tintColor = .yellow
        shareIcon.image = UIImage.asset(named: "share")
        shareIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            shareIcon.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            shareIcon.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            shareIcon.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            shareIcon.widthAnchor.constraint(equalToConstant: 24),
            shareIcon.heightAnchor.constraint(equalTo: shareIcon.widthAnchor)
        ])
    }
    
}
