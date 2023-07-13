//
//  TaskScreenTopPanel.swift
//  DetectItUI
//
//  Created by Илья Харабет on 13.09.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public final class TaskScreenTopPanel: UIView {
    
    public var onClose: (() -> Void)?
    public var onNotes: (() -> Void)?
    public var onShare: (() -> Void)?
    
    private var gradientView = GradientView()
    
    public let closeButton = SolidButton.closeButton()
    
    private let buttonsContainer = UIStackView()
    public let notesButton = SolidButton.plainButton(icon: "notes")
    public let shareButton = SolidButton.plainButton(icon: "share")
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func didTapCloseButton() {
        onClose?()
    }
    
    @objc private func didTapNotesButton() {
        onNotes?()
    }
    
    @objc private func didTapShareButton() {
        onShare?()
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
            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
        addSubview(buttonsContainer)
        buttonsContainer.axis = .horizontal
        buttonsContainer.spacing = 12
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            buttonsContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])
        
        buttonsContainer.addArrangedSubview(notesButton)
        notesButton.addTarget(self, action: #selector(didTapNotesButton), for: .touchUpInside)
        
        buttonsContainer.addArrangedSubview(shareButton)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    }
    
}
