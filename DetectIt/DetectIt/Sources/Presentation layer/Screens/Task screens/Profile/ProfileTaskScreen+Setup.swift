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
        contentContainer.view.backgroundColor = .black
        
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
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.crimeDescriptionLabel)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.answersView)
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
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        if !User.shared.isProfileHelpShown {
            view.addSubview(helpButton)
            
            helpButton.addTarget(self, action: #selector(didTapHelpButton), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                helpButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
                helpButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            ])
        }
        
        screenView.setupViews()
    }
    
    func setupScreenLoadingView() {
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
    }
    
}
