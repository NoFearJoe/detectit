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
        
        contentContainer.view.backgroundColor = .black
                
        contentContainer.scrollView.clipsToBounds = false
        
        contentContainer.setTopSpacing(52)
        contentContainer.appendChild(screenView.titleLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.prepositionLabel)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.encodedPictureContainer)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.questionAndAnswerView)
        contentContainer.appendSpacing(Constants.spacingBeforeScore)
        contentContainer.appendChild(screenView.answerButton)
        contentContainer.appendChild(screenView.scoreLabel)
        contentContainer.appendSpacing(40)
        contentContainer.appendChild(screenView.rightAnswerView)
        contentContainer.appendSpacing(20)
        contentContainer.appendChild(screenView.crimeDescriptionLabel)
        contentContainer.setBottomSpacing(Constants.bottomInset)
        
        let backgroundTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer.delegate = self
        contentContainer.scrollView.addGestureRecognizer(backgroundTapRecognizer)
        
        let backgroundTapRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        backgroundTapRecognizer1.delegate = self
        contentContainer.stackView.addGestureRecognizer(backgroundTapRecognizer1)
    }
    
    func setupViews() {
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        if !User.shared.isDecoderHelpShown {
            view.addSubview(helpButton)
            
            helpButton.addTarget(self, action: #selector(didTapHelpButton), for: .touchUpInside)
            
            NSLayoutConstraint.activate([
                helpButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
                helpButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            ])
        }
        
        screenView.setupViews()
        
        screenView.onTapEncodedPicture = didTapEncodedPicture
        screenView.onTapAnswerButton = didTapAnswerButton
    }
    
    func setupScreenLoadingView() {
        view.addSubview(screenLoadingView)
        screenLoadingView.pin(to: view)
    }
    
}
