//
//  ProfileView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import DetectItUI

public protocol ProfileViewDelegate: AnyObject {
    func preposition() -> ProfilePrepositionCell.Model
    
    func numberOfCases() -> Int
    func `case`(at index: Int) -> ProfileCaseCell.Model?
    func didSelectEvidence(at index: Int)
}

public final class ProfileView: UIView {
    
    // MARK: - External dependencies
    
    private unowned let delegate: ProfileViewDelegate
    
    // MARK: - Subviews
    
    private let listLayout = UICollectionViewFlowLayout()
    
    public lazy var listView = AutosizingCollectionView(
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
    
    // MARK: - Public functions
    
    public func reloadData() {
        listView.reloadData()
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
        
        listView.registerEmptyCell()
        listView.register(ProfileCaseCell.self, forCellWithReuseIdentifier: ProfileCaseCell.identifier)
        listView.register(ProfilePrepositionCell.self, forCellWithReuseIdentifier: ProfilePrepositionCell.identifier)
        
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
        default: return collectionView.dequeueEmptyCell(for: indexPath)
        }
    }
    
}

extension ProfileView: UICollectionViewDelegate {}

extension ProfileView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 20
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        guard self.collectionView(collectionView, numberOfItemsInSection: section) > 0 else { return .zero }
        
        return UIEdgeInsets(top: section == 0 ? 0 : 20, left: 0, bottom: 20, right: 0)
    }
    
}

private extension ProfileView {
    
    enum Section: Int {
        case preposition = 0, cases
    }
    
}
