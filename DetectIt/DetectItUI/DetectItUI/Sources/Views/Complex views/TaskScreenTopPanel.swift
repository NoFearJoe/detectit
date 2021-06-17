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
    
    private var blurView = BlurView(style: .dark)
    
    public let closeButton = SolidButton.closeButton()
    
    private let buttonsContainer = UIStackView()
    public let notesButton = SolidButton.notesButton()
    
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
    
    private func setupViews() {
        addSubview(blurView)
        blurView.blurRadius = 20
        blurView.colorTint = UIColor.black.withAlphaComponent(0.5)
        blurView.pin(to: self)
        
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
    }
    
}
