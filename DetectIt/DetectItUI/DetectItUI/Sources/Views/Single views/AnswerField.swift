//
//  AnswerField.swift
//  DetectItUI
//
//  Created by Илья Харабет on 04/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import NextGrowingTextView

final class AnswerField: UIView {
    
    var onChangeText: ((String) -> Void)?
    
    var answer: String {
        textField.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.textView.keyboardType = keyboardType
        }
    }
    
    func highlight(isCorrect: Bool, animated: Bool, animationDuration: TimeInterval) {
        UIView.animate(withDuration: animated ? animationDuration : 0) {
            self.bottomLineView.backgroundColor = isCorrect ? .green : .red
        }
    }
    
    // MARK: - Subviews
    
    private let textField = NextGrowingTextView()
    private let bottomLineView = UIView()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @objc private func didChangeText() {
        onChangeText?(answer)
    }
    
    // MARK: - Setup
    
    private func setup() {
        textField.textView.textColor = .white
        textField.textView.tintColor = .yellow
        textField.textView.font = .text2
        textField.textView.autocorrectionType = .no
        textField.textView.keyboardAppearance = .dark
        textField.textView.autocapitalizationType = .none
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangeText),
            name: UITextView.textDidChangeNotification,
            object: textField.textView
        )
    }
    
    private func setupViews() {
        addSubview(textField)
        
        textField.pin(
            to: self,
            insets: UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        )
        
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
