//
//  ProfileTaskScreen+Setup.swift
//  DetectIt
//
//  Created by Илья Харабет on 06/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension ProfileTaskScreen {
    
    func setupContentView() {
        contentContainer.view.backgroundColor = .systemBackground
        
        contentContainer.scrollView.clipsToBounds = false
        
        contentContainer.setTopSpacing(52)
        contentContainer.appendChild(screenView.profileView)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.reportTitleView)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.reportView)
        contentContainer.appendSpacing(Constants.spacingBeforeScore)
        contentContainer.appendChild(screenView.answerButton)
        contentContainer.appendChild(screenView.scoreLabel)
        contentContainer.appendSpacing(32)
        contentContainer.appendChild(screenView.crimeDescriptionTitleView)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.crimeDescriptionView)
        contentContainer.appendChild(screenView.hiddenCrimeDescriptionView)
        contentContainer.appendSpacing(32)
        contentContainer.appendChild(screenView.answersTitleView)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.answersView)
        contentContainer.appendSpacing(28)
        contentContainer.appendChild(rateTaskViewController)
        contentContainer.setBottomSpacing(Constants.bottomInset)
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer.delegate = self
        contentContainer.scrollView.addGestureRecognizer(backgroundTapRecognizer)
        
        let backgroundTapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer1.delegate = self
        contentContainer.stackView.addGestureRecognizer(backgroundTapRecognizer1)
        
        let backgroundTapRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer2.delegate = self
        screenView.profileView.listView.addGestureRecognizer(backgroundTapRecognizer2)
    }
    
    func setupViews() {
        view.addSubview(topPanel)
        
        topPanel.helpButton.isHidden = User.shared.isProfileHelpShown
        topPanel.onClose = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        topPanel.onHelp = { [unowned self] in
            User.shared.isProfileHelpShown = true
            
            self.topPanel.helpButton.isHidden = true
            
            present(HelpScreen(taskKind: self.task.kind), animated: true, completion: nil)
        }
        topPanel.onNotes = { [unowned self] in
            self.present(TaskNotesScreen(task: self.task), animated: true, completion: nil)
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
