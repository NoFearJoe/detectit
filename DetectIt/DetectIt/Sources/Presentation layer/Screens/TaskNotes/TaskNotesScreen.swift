
//
//  TaskNotesScreen.swift
//  DetectIt
//
//  Created by Илья Харабет on 20.08.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI
import DetectItCore

final class TaskNotesScreen: Screen {
    
    private let closeButton = SolidButton.closeButton()
    private let titleLabel = UILabel()
    private let textView = UITextView()
    
    private let task: Task
    
    init(task: Task) {
        self.task = task
        
        super.init(nibName: nil, bundle: nil)
        
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        titleLabel.font = .heading1
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.text = "task_notes_screen_title".localized
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        view.addSubview(textView)
        textView.text = "task_notes_screen_notes_placeholder".localized
        textView.font = .text2
        textView.textColor = .lightGray
        textView.tintColor = .yellow
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .sentences
        textView.returnKeyType = .done
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    override func prepare() {
        if let cacehdNotes = getCachedNotes(), !cacehdNotes.isEmpty {
            textView.text = cacehdNotes
            textView.textColor = .white
        } else {
            textView.text = "task_notes_screen_notes_placeholder".localized
            textView.textColor = .lightGray
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cacheNotes()
    }
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func cacheNotes() {
        guard textView.textColor != .lightGray else { return }
        
        UserDefaults.standard.set(
            textView.text,
            forKey: task.kind.rawValue + "_" + task.id
        )
    }
    
    private func getCachedNotes() -> String? {
        UserDefaults.standard.string(
            forKey: task.kind.rawValue + "_" + task.id
        )
    }
    
}

extension TaskNotesScreen: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .lightGray else { return }
        
        textView.text = nil
        textView.textColor = .white
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView.text.isEmpty else { return }
        
        textView.text = "task_notes_screen_notes_placeholder".localized
        textView.textColor = .lightGray
    }
    
}
