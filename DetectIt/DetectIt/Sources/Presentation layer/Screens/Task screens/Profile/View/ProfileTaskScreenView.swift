//
//  ProfileTaskScreenView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 09/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public protocol ProfileTaskScreenViewDelegate: ProfileViewDelegate, AttachmentsViewDelegate, ProfileReportViewDelegate {
    
    func didTapAnswerButton()
    
    func numberOfAnswers() -> Int
    func answer(at index: Int) -> ProfileTaskAnswerCell.Model?
    
    func didTapGetStatusButton()
    
}

public final class ProfileTaskScreenView: NSObject {
    
    public let profileView: ProfileView
    public let attachmentsView: AttachmentsView
    
    public let reportTitleView = ListSectionHeaderView()
    public let reportView: ProfileReportView
    
    public let answerButton = AnswerButton()
    
    public let scoreLabel = UILabel()
    
    public let crimeDescriptionTitleView = ListSectionHeaderView()
    public let crimeDescriptionView = TextView()
    public let hiddenCrimeDescriptionView = ProfileHiddenCrimeDescriptionView()
    
    public let answersTitleView = ListSectionHeaderView()
    private let listLayout = UICollectionViewFlowLayout()
    public lazy var answersView = AutosizingCollectionView(
        frame: .zero,
        collectionViewLayout: listLayout
    )
    
    private unowned let delegate: ProfileTaskScreenViewDelegate
    
    public init(delegate: ProfileTaskScreenViewDelegate) {
        self.delegate = delegate
        self.profileView = ProfileView(delegate: delegate)
        self.attachmentsView = AttachmentsView(delegate: delegate)
        self.reportView = ProfileReportView(delegate: delegate)
        
        super.init()
    }
    
    public func reloadContent() {
        profileView.reloadData()
        attachmentsView.reloadData()
        reportView.reloadData()
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
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        
        // Crime description
        
        crimeDescriptionTitleView.titleLabel.textAlignment = .center
        crimeDescriptionTitleView.configure(title: "profile_task_screen_crime_description_title".localized)
        crimeDescriptionTitleView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        hiddenCrimeDescriptionView.onTapGetStatusButton = { [unowned delegate] in
            delegate.didTapGetStatusButton()
        }
        
        // Answers
        
        answersTitleView.titleLabel.textAlignment = .center
        answersTitleView.configure(title: "profile_task_screen_answers_title".localized)
        answersTitleView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        answersView.delegate = self
        answersView.dataSource = self
        answersView.showsVerticalScrollIndicator = false
        answersView.register(ProfileTaskAnswerCell.self, forCellWithReuseIdentifier: ProfileTaskAnswerCell.identifier)
    }
    
}

extension ProfileTaskScreenView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        delegate.numberOfAnswers()
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileTaskAnswerCell.identifier,
            for: indexPath
        ) as! ProfileTaskAnswerCell
        
        if let model = delegate.answer(at: indexPath.item) {
            cell.configure(model: model)
        }
        
        return cell
    }
    
}

extension ProfileTaskScreenView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }
    
}
