//
//  QuestTaskScreen+Setup.swift
//  DetectIt
//
//  Created by Илья Харабет on 19.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension QuestTaskScreen {
    
    func setupContentView() {
        contentContainer.view.backgroundColor = .systemBackground
        
        contentContainer.scrollView.clipsToBounds = false
        
        contentContainer.setTopSpacing(52)
        contentContainer.appendChild(screenView.prepositionView.contentView)
        contentContainer.appendSpacing(32)
        contentContainer.appendChild(screenView.chaptersContainerView)
        contentContainer.appendSpacing(Constants.spacingBeforeScore)
        contentContainer.appendChild(screenView.scoreLabel)
        contentContainer.appendSpacing(32)
        contentContainer.appendChild(screenView.endingTitleView)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.endingTextLabel)
        contentContainer.appendSpacing(28)
        contentContainer.appendChild(rateTaskViewController)
        contentContainer.appendSpacing(28)
        contentContainer.appendChild(taskSharingViewController)
        contentContainer.setBottomSpacing(Constants.bottomInset)
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer.delegate = self
        contentContainer.scrollView.addGestureRecognizer(backgroundTapRecognizer)
        
        let backgroundTapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer1.delegate = self
        contentContainer.stackView.addGestureRecognizer(backgroundTapRecognizer1)
    }
    
    func setupViews() {
        view.addSubview(topPanel)
        
        topPanel.onClose = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        topPanel.onNotes = { [unowned self] in
            self.present(TaskNotesScreen(task: self.state.task), animated: true, completion: nil)
        }
        
        topPanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topPanel.topAnchor.constraint(equalTo: view.topAnchor),
            topPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        screenView.setupViews()
    }
    
    func setupScreenLoadingView() {
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
    }
    
}

