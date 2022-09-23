//
//  BlitzTaskScreenView.swift
//  DetectIt
//
//  Created by Илья Харабет on 21.11.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public protocol BlitzTaskScreenViewDelegate: ProfileViewDelegate, AttachmentsViewDelegate, ProfileReportViewDelegate {
    
    func didTapAnswerButton()
    
    func answerModel() -> ProfileTaskAnswerCell.Model?
    
    func didTapGetStatusButton()
    
}

public final class BlitzTaskScreenView: NSObject {
    
    public let profileView: ProfileView
    public let attachmentsView: AttachmentsView
    
    public let reportTitleView = ListSectionHeaderView()
    public let reportView: ProfileReportView
    
    public let answerButton = AnswerButton()
    
    public let scoreLabel = UILabel()
    
    public let crimeDescriptionTitleView = ListSectionHeaderView()
    public let crimeDescriptionView = TextView()
    public let hiddenCrimeDescriptionView = ProfileHiddenCrimeDescriptionView()
    public let crimeDescriptionAttachmentsView: AttachmentsView
    
    public let rightAnswerView = DecoderTaskRightAnswerView()
    
    private unowned let delegate: BlitzTaskScreenViewDelegate
    
    public init(delegate: BlitzTaskScreenViewDelegate) {
        self.delegate = delegate
        self.profileView = ProfileView(delegate: delegate)
        self.attachmentsView = AttachmentsView(delegate: delegate)
        self.reportView = ProfileReportView(delegate: delegate)
        self.crimeDescriptionAttachmentsView = AttachmentsView(delegate: delegate)
        
        super.init()
    }
    
    public func reloadContent() {
        profileView.reloadData()
        attachmentsView.reloadData()
        reportView.reloadData()
        crimeDescriptionAttachmentsView.reloadData()
        
        rightAnswerView.answer = delegate.answerModel()?.answer
    }
    
    public func setupViews() {
        reportTitleView.titleLabel.textAlignment = .center
        reportTitleView.configure(title: "profile_task_screen_report_title".localized)
        reportTitleView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        answerButton.isEnabled = false
        answerButton.titleLabel.text = "profile_task_screen_send_report_button_title".localized
        answerButton.onFill = { [unowned self] in
            self.delegate.didTapAnswerButton()
        }
        
        scoreLabel.font = .score1
        scoreLabel.textColor = .softWhite
        scoreLabel.textAlignment = .center
                
        // Crime description
        
        crimeDescriptionTitleView.titleLabel.textAlignment = .center
        crimeDescriptionTitleView.configure(title: "profile_task_screen_crime_description_title".localized)
        crimeDescriptionTitleView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        hiddenCrimeDescriptionView.onTapGetStatusButton = { [unowned delegate] in
            delegate.didTapGetStatusButton()
        }
    }
    
}
