import SwiftUI
import NextGrowingTextView

public struct AnswerFieldSUI: UIViewRepresentable {
    let kind: AnswerField.Kind
    let keyboardType: UIKeyboardType
    @Binding var text: String
    
    public init(kind: AnswerField.Kind, keyboardType: UIKeyboardType, text: Binding<String>) {
        self.kind = kind
        self.keyboardType = keyboardType
        self._text = text
    }
    
    public func makeUIView(context: Context) -> AnswerField {
        AnswerField(kind: kind)
    }
    
    public func updateUIView(_ uiView: AnswerField, context: Context) {
        uiView.answer = text
        uiView.keyboardType = keyboardType
        uiView.onChangeText = {
            text = $0
        }
    }
}

public final class AnswerField: UIView {
    
    public enum Kind {
        case textView, textField
    }
    
    var onChangeText: ((String) -> Void)?
    
    var answer: String {
        get {
            switch kind {
            case .textField:
                return (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            case .textView:
                return textView.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        set {
            switch kind {
            case .textField:
                textField.text = newValue
            case .textView:
                textView.textView.text = newValue
            }
        }
    }
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            switch kind {
            case .textField:
                textField.keyboardType = keyboardType
            case .textView:
                textView.textView.keyboardType = keyboardType
            }
        }
    }
    
    func highlight(isCorrect: Bool?, animated: Bool, animationDuration: TimeInterval) {
        UIView.animate(withDuration: animated ? animationDuration : 0) {
            if let isCorrect = isCorrect {
                self.bottomLineView.backgroundColor = isCorrect ? .green : .red
            } else {
                self.bottomLineView.backgroundColor = .lightGray
            }
        }
    }
    
    // MARK: - Subviews
    
    public let textView = NextGrowingTextView()
    public let textField = UITextField()
    private let bottomLineView = UIView()
    
    // MARK: - Init
    
    private let kind: Kind
    
    public init(kind: Kind) {
        self.kind = kind
        
        super.init(frame: .zero)
        
        setup(kind: kind)
        setupViews(kind: kind)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func becomeFirstResponder() -> Bool {
        switch kind {
        case .textField:
            return textField.becomeFirstResponder()
        case .textView:
            return textView.becomeFirstResponder()
        }
    }
    
    public override func resignFirstResponder() -> Bool {
        switch kind {
        case .textField:
            return textField.resignFirstResponder()
        case .textView:
            return textView.resignFirstResponder()
        }
    }
    
    public override var isFirstResponder: Bool {
        switch kind {
        case .textField:
            return textField.isFirstResponder
        case .textView:
            return textView.isFirstResponder
        }
    }
    
    // MARK: - Actions
    
    @objc private func didChangeText() {
        onChangeText?(answer)
    }
    
    // MARK: - Setup
    
    private func setup(kind: Kind) {
        switch kind {
        case .textView:
            textView.maxNumberOfLines = 10
            textView.textView.textColor = .softWhite
            textView.textView.tintColor = .yellow
            textView.textView.font = .text2
            textView.textView.autocorrectionType = .no
            textView.textView.keyboardAppearance = .dark
            textView.textView.autocapitalizationType = .none
            textView.showsVerticalScrollIndicator = false
            textView.showsHorizontalScrollIndicator = false
            textView.textView.showsVerticalScrollIndicator = false
            textView.textView.showsHorizontalScrollIndicator = false
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didChangeText),
                name: UITextView.textDidChangeNotification,
                object: textView.textView
            )
        case .textField:
            textField.textColor = .softWhite
            textField.tintColor = .yellow
            textField.font = .text2
            textField.autocorrectionType = .no
            textField.keyboardAppearance = .dark
            textField.autocapitalizationType = .none
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didChangeText),
                name: UITextField.textDidChangeNotification,
                object: textField
            )
        }
    }
    
    private func setupViews(kind: Kind) {
        let textView = kind == .textField ? self.textField : self.textView
        let insets: CGFloat = kind == .textField ? 6 : 4
        
        addSubview(textView)
        
        textView.pin(
            to: self,
            insets: UIEdgeInsets(top: insets, left: 0, bottom: -insets, right: 0)
        )
        
        if kind == .textField {
            textView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        }
        
        addSubview(bottomLineView)
        
        bottomLineView.backgroundColor = .lightGray
        
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomLineView.heightAnchor.constraint(equalToConstant: 2),
            bottomLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomLineView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
