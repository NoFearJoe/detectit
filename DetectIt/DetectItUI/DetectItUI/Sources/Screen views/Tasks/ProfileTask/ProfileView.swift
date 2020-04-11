//
//  ProfileView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol ProfileViewDelegate: AnyObject {
    func preposition() -> ProfilePrepositionCell.Model
    
    func numberOfCases() -> Int
    func `case`(at index: Int) -> ProfileCaseCell.Model?
    func didSelectEvidence(at index: Int)

    func numberOfAttachments() -> Int
    func attachment(at index: Int) -> Any?
    func didSelectAttachment(at index: Int)
    
    func numberOfQuestions() -> Int
    func question(at index: Int) -> (question: Any, isCorrect: Bool?)?
}

public final class ProfileView: UIView {
    
    // MARK: - External dependencies
    
    private unowned let delegate: ProfileViewDelegate
    
    // MARK: - Subviews
    
    private let listLayout = UICollectionViewFlowLayout()
    
    private lazy var listView = AutosizingCollectionView(
        frame: .zero,
        collectionViewLayout: listLayout
    )
    
    // MARK: - Init
    
    public init(delegate: ProfileViewDelegate) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        setup()
        setupListView()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Overrides
    
    public override var bounds: CGRect {
        didSet {
            guard bounds != .zero else { return }
            
            let width = bounds.width - listView.contentInset.left - listView.contentInset.right
            listLayout.estimatedItemSize = CGSize(
                width: max(width, 0),
                height: 0
            )
        }
    }
    
    // MARK: - Public functions
    
    public func reloadData() {
        listView.reloadData()
    }
    
    public func getAnswerCell(at index: Int) -> ProfileTaskAnyAnswerCell? {
        listView.cellForItem(
            at: IndexPath(item: index, section: Section.questions.rawValue)
        ) as? ProfileTaskAnyAnswerCell
    }
    
    // MARK: - Setup
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupListView() {
        addSubview(listView)
        
        listView.delegate = self
        listView.dataSource = self
        listView.backgroundColor = nil
        listView.showsVerticalScrollIndicator = false
        
        listView.register(ProfileCaseCell.self, forCellWithReuseIdentifier: ProfileCaseCell.identifier)
        listView.register(ProfilePrepositionCell.self, forCellWithReuseIdentifier: ProfilePrepositionCell.identifier)
        listView.register(ProfilePhotoAttachmentCell.self, forCellWithReuseIdentifier: ProfilePhotoAttachmentCell.identifier)
        listView.register(ProfileTaskNumberQuestionCell.self, forCellWithReuseIdentifier: ProfileTaskNumberQuestionCell.identifier)
        listView.register(ProfileTaskExactAnswerQuestionCell.self, forCellWithReuseIdentifier: ProfileTaskExactAnswerQuestionCell.identifier)
        listView.register(ProfileTaskVariantsQuestionCell.self, forCellWithReuseIdentifier: ProfileTaskVariantsQuestionCell.identifier)
        listView.register(ProfileTaskBoolAnswerQuestionCell.self, forCellWithReuseIdentifier: ProfileTaskBoolAnswerQuestionCell.identifier)
        
        listView.register(
            ListSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ListSectionHeaderView.identifier
        )
        
        listView.pin(to: self)
    }
    
}

extension ProfileView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .preposition: return 1
        case .cases: return delegate.numberOfCases()
        case .attachments: return delegate.numberOfAttachments()
        case .questions: return delegate.numberOfQuestions()
        default: return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .preposition:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePrepositionCell.identifier, for: indexPath) as! ProfilePrepositionCell
            
            cell.configure(model: delegate.preposition())
            
            return cell
        case .cases:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCaseCell.identifier, for: indexPath) as! ProfileCaseCell
            
            if let model = delegate.case(at: indexPath.item) {
                cell.configure(model: model)
            }
            
            cell.onTapEvidence = { [unowned delegate] in
                delegate.didSelectEvidence(at: indexPath.item)
            }
            
            return cell
        case .attachments:
            guard let model = delegate.attachment(at: indexPath.item) else { return UICollectionViewCell() }
            
            if let photoAttachment = model as? ProfilePhotoAttachmentCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProfilePhotoAttachmentCell.identifier,
                    for: indexPath
                ) as! ProfilePhotoAttachmentCell
                
                cell.configure(model: photoAttachment)
                cell.onTapPhoto = { [unowned self] in
                    self.delegate.didSelectAttachment(at: indexPath.item)
                }
                
                return cell
            } else {
                return UICollectionViewCell()
            }
        case .questions:
            guard let model = delegate.question(at: indexPath.item) else { return UICollectionViewCell() }
            
            if let numberQuestionModel = model.question as? ProfileTaskNumberQuestionCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProfileTaskNumberQuestionCell.identifier,
                    for: indexPath
                ) as! ProfileTaskNumberQuestionCell
                
                cell.configure(model: numberQuestionModel)
                cell.setEnabled(model.isCorrect == nil)
                
                if let isCorrect = model.isCorrect {
                    cell.highlight(isCorrect: isCorrect, animated: false, animationDuration: 0)
                }
                
                return cell
            } else if let exactAnswerQuestionModel = model.question as? ProfileTaskExactAnswerQuestionCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProfileTaskExactAnswerQuestionCell.identifier,
                    for: indexPath
                ) as! ProfileTaskExactAnswerQuestionCell
                
                cell.configure(model: exactAnswerQuestionModel)
                cell.setEnabled(model.isCorrect == nil)
                
                if let isCorrect = model.isCorrect {
                    cell.highlight(isCorrect: isCorrect, animated: false, animationDuration: 0)
                }
                
                return cell
            } else if let variantsQuestionModel = model.question as? ProfileTaskVariantsQuestionCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProfileTaskVariantsQuestionCell.identifier,
                    for: indexPath
                ) as! ProfileTaskVariantsQuestionCell
                
                cell.configure(model: variantsQuestionModel)
                cell.setEnabled(model.isCorrect == nil)
                
                if let isCorrect = model.isCorrect {
                    cell.highlight(isCorrect: isCorrect, animated: false, animationDuration: 0)
                }
                
                return cell
            } else if let boolAnswerQuestionModel = model.question as? ProfileTaskBoolAnswerQuestionCell.Model {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProfileTaskBoolAnswerQuestionCell.identifier,
                    for: indexPath
                ) as! ProfileTaskBoolAnswerQuestionCell
                
                cell.configure(model: boolAnswerQuestionModel)
                cell.setEnabled(model.isCorrect == nil)
                
                if let isCorrect = model.isCorrect {
                    cell.highlight(isCorrect: isCorrect, animated: false, animationDuration: 0)
                }
                
                return cell
            } else {
                return UICollectionViewCell()
            }
        default: return UICollectionViewCell()
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ListSectionHeaderView.identifier,
            for: indexPath
        ) as! ListSectionHeaderView
        
        if let title = Section(rawValue: indexPath.section)?.title {
            view.configure(title: title)
        }
        
        view.layoutMargins = .zero
        view.titleLabel.font = .heading2
        view.titleLabel.textAlignment = .center
        
        return view
    }
    
}

extension ProfileView: UICollectionViewDelegate {
    
    
    
}

extension ProfileView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        switch Section(rawValue: section) {
        case .questions:
            return 40
        default:
            return 20
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard self.collectionView(collectionView, numberOfItemsInSection: section) > 0 else { return .zero }
        
        return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        guard
            self.collectionView(collectionView, numberOfItemsInSection: section) > 0,
            Section(rawValue: section)?.title != nil
        else { return .zero }
        
        return CGSize(width: collectionView.bounds.width, height: 52)
    }
    
}

private extension ProfileView {
    
    enum Section: Int {
        case preposition = 0, cases, attachments, questions
        
        var title: String? {
            switch self {
            case .preposition, .cases:
                return nil
            case .attachments:
                return "Дополнения"
            case .questions:
                return "Отчет"
            }
        }
    }
    
}
