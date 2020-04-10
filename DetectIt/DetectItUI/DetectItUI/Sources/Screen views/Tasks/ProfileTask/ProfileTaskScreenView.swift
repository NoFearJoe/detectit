//
//  ProfileTaskScreenView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol ProfileTaskScreenViewDelegate: ProfileViewDelegate {
    
    func didTapAnswerButton()
    
}

public final class ProfileTaskScreenView {
    
    public let profileView: ProfileView
    
    public let answerButton = AnswerButton()
    
    public let scoreLabel = UILabel()
    public let crimeDescriptionLabel = UILabel()
    
    private let delegate: ProfileTaskScreenViewDelegate
    
    public init(delegate: ProfileTaskScreenViewDelegate) {
        self.delegate = delegate
        self.profileView = ProfileView(delegate: delegate)
    }
    
    public func reloadContent() {
        profileView.reloadData()
    }
    
    public func setupViews() {
        answerButton.isEnabled = false
        //        answerButton.setTitle("Отправить ответ", for: .normal) // TODO
        answerButton.onFill = { [unowned self] in
            self.delegate.didTapAnswerButton()
        }
        
        scoreLabel.font = .score1
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        
        crimeDescriptionLabel.font = .text3
        crimeDescriptionLabel.textColor = .white
        crimeDescriptionLabel.numberOfLines = 0
    }
    
}
