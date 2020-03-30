//
//  ProfileView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol ProfileViewDelegate: AnyObject {
    func preposition() -> ProfileCaseCell.Model?
    
    func numberOfCases() -> Int
    func `case`(at index: Int) -> ProfileCaseCell.Model?
    func didSelectEvidence(at index: Int)

    func numberOfAttachments() -> Int
    func attachment(at index: Int) -> Any?
    func didSelectAttachment(at index: Int)
}

public final class ProfileView: UIView {
    
    // MARK: - External dependencies
    
    private unowned let delegate: ProfileViewDelegate
    
    // MARK: - Subviews
    
    private let listLayout = UICollectionViewFlowLayout()
    
    private lazy var listView = UICollectionView(
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
                height: max(width, 0) * 9/16
            )
        }
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
        listView.contentInset = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        
        listView.register(ProfileCaseCell.self, forCellWithReuseIdentifier: ProfileCaseCell.identifier)
        listView.register(ProfilePhotoAttachmentCell.self, forCellWithReuseIdentifier: ProfilePhotoAttachmentCell.identifier)
        
        listView.pin(to: self)
    }
    
}

extension ProfileView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .preposition: return 0
        case .cases: return delegate.numberOfCases()
        case .attachments: return delegate.numberOfAttachments()
        case .questions: return 0
        default: return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .preposition: return UICollectionViewCell()
        case .cases:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCaseCell.identifier, for: indexPath) as! ProfileCaseCell
            
            if let model = delegate.case(at: indexPath.item) {
                cell.configure(model: model)
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
                
                return cell
            } else {
                return UICollectionViewCell()
            }
        case .questions: return UICollectionViewCell()
        default: return UICollectionViewCell()
        }
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
        20
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
}

private extension ProfileView {
    
    enum Section: Int {
        case preposition = 0, cases, attachments, questions
    }
    
}

// MARK: - For testing purposes

final class MockProfileViewDelegate: ProfileViewDelegate {
    
    func preposition() -> ProfileCaseCell.Model? {
        nil
    }
    
    func numberOfCases() -> Int {
        2
    }
    
    func `case`(at index: Int) -> ProfileCaseCell.Model? {
        ProfileCaseCell.Model(
            case: PaperSheetView.Model(
                title: "Колорадский маньяк",
                text: "Далеко на юге штата Колорадо орудовал маньяк, которого в будущем полиция прозвала \"Колорадский маньяк\", потому что он убивал своих жертв картошкой. Полиция так и не смогла поймать его, потому что слишком сильно тупила."
            ),
            evidence: EvidenceCell.Model(
                photo: UIImage.asset(named: "Test")!,//.applyingOldPhotoFilter(),
                title: "#\(index) Зацепочка"
            )
        )
    }
    
    func didSelectEvidence(at index: Int) {
        
    }
    
    func numberOfAttachments() -> Int {
        1
    }
    
    func attachment(at index: Int) -> Any? {
        ProfilePhotoAttachmentCell.Model(title: "Люди на блюде", photo: UIImage.asset(named: "Test")!)
    }
    
    func didSelectAttachment(at index: Int) {
        
    }
    
}
