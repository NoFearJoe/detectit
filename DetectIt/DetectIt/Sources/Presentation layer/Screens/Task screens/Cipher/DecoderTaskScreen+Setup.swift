//
//  DecoderTaskScreen+Setup.swift
//  DetectIt
//
//  Created by Илья Харабет on 06/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItCore

extension DecoderTaskScreen {
    
    func setupContentView() {
        contentContainer.place(into: self) {
            $0.pin(to: self.view, insets: UIEdgeInsets(top: 0, left: .hInset, bottom: 0, right: -.hInset))
        }
        
        contentContainer.view.backgroundColor = .systemBackground
                
        contentContainer.scrollView.clipsToBounds = false
        
        contentContainer.setTopSpacing(52)
        contentContainer.appendChild(screenView.titleLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.prepositionLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.encodedPictureContainer)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.audioPlayerController)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.questionAndAnswerView)
        contentContainer.appendSpacing(Constants.spacingBeforeScore)
        contentContainer.appendChild(screenView.answerButton)
        contentContainer.appendChild(screenView.scoreLabel)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.rightAnswerView)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.crimeDescriptionLabel)
        contentContainer.appendSpacing(28)
        contentContainer.appendChild(rateTaskViewController)
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
        
        topPanel.helpButton.isHidden = User.shared.isDecoderHelpShown
        topPanel.onClose = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        topPanel.onHelp = { [unowned self] in
            User.shared.isDecoderHelpShown = true
            
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
        
        screenView.onTapEncodedPicture = { [unowned self] in
            self.didTapEncodedPicture()
        }
        screenView.onTapAnswerButton = { [unowned self] in
            self.didTapAnswerButton()
        }
    }
    
    func setupScreenLoadingView() {
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
    }
    
}
