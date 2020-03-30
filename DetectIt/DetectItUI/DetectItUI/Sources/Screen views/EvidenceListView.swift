//
//  EvidenceListView.swift
//  DetectItUI
//
//  Created by Илья Харабет on 30/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

public protocol EvidenceListViewDelegate: AnyObject {
    
    func numberOfEvidences() -> Int
    
    func evidenceModel(at index: Int) -> EvidenceCell.Model?
    
    func didSelectEvidence(at index: Int)
    
}

public final class EvidenceListView: UIView {
    
    // MARK: - External dependencies
    
    public unowned let delegate: EvidenceListViewDelegate
    
    public init(delegate: EvidenceListViewDelegate) {
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        setup()
        setupListView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Subviews
    
    private let listLayout = ItemsOnTableLayout()
    
    private lazy var listView = UICollectionView(
        frame: .zero,
        collectionViewLayout: listLayout
    )
    
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
    
}

extension EvidenceListView: UICollectionViewDataSource {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        delegate.numberOfEvidences()
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EvidenceCell.identifier, for: indexPath) as! EvidenceCell
        
        if let model = delegate.evidenceModel(at: indexPath.item) {
            cell.configure(model: model)
        }
        
        return cell
    }
    
}

extension EvidenceListView: UICollectionViewDelegate {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        delegate.didSelectEvidence(at: indexPath.item)
    }
    
}

extension EvidenceListView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        20
    }
    
}

private extension EvidenceListView {
    
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
        
        listView.register(EvidenceCell.self, forCellWithReuseIdentifier: EvidenceCell.identifier)
        
        listView.pin(to: self)
    }
    
}

// MARK: - For testing purposes

final class MockEvidenceListViewDelegate: EvidenceListViewDelegate {
    
    func numberOfEvidences() -> Int {
        4
    }
    
    func evidenceModel(at index: Int) -> EvidenceCell.Model? {
        EvidenceCell.Model(
            photo: UIImage.asset(named: "Test")!,
            title: "#\(index) Зацепочка"
        )
    }
    
    func didSelectEvidence(at index: Int) {}
    
}
